import Base.StatusActive, Base.StatusOpen, Base.StatusPaused

abstract type RedisConnectionBase end

mutable struct RedisConnection <: RedisConnectionBase
    host::AbstractString
    port::Integer
    password::AbstractString
    db::Integer
    socket::TCPSocket
end

function RedisConnection(; host="127.0.0.1", port=6379, password= "", db=0)
    try
        socket = connect(host, port)
        connection = RedisConnection(host, port, password, db, socket)
        on_connect(connection)
    catch
        throw("Failed to connect to Redis server")
    end
end

function RedisConnection(conn::RedisConnection)
    try
        socket = connect(conn.host, conn.port)
        connection = RedisConnection(conn.host, conn.port, conn.password, conn.db, socket)
        on_connect(connection)
    catch
        throw("Failed to connect to Redis server")
    end
end

@inline reconnect(conn::RedisConnectionBase) = (conn.socket = connect(conn.host, conn.port))

@inline function on_connect(conn::RedisConnectionBase)
    conn.password != "" && auth(conn, conn.password)
    conn.db != 0        && select(conn, conn.db)
    conn
end

@inline disconnect(conn::RedisConnectionBase) = close(conn.socket)
@inline is_connected(conn::RedisConnectionBase) =conn.socket.status in [StatusActive ,StatusOpen,StatusPaused]
@inline send_command(conn::RedisConnectionBase, command::AbstractString) =write(conn.socket, command)

# redis 回复消息解析
struct redisreply{T} end 

function reply(conn::TCPSocket)
    tmp = readline(conn)  
    syms, value = tmp[1] , tmp[2:end]
    reply(redisreply{Symbol(syms)}, value, conn)
end 

function reply(::Type{redisreply{:*}}, value::AbstractString, conn::TCPSocket) 
    num = parse(Int, value)
    num == -1 && return nothing
    num == 0 && return Int[]
    res = Vector{Union{Int, AbstractString}}(undef, num)
    @inbounds for i in 1:num
        res[i] = reply(conn)
    end 
    return res 
end 

function reply(::Type{redisreply{:$}}, value::AbstractString, conn::TCPSocket)
    num = parse(Int, value)
    num == -1 ? nothing : read(conn, num +2) |> q -> view(q, 1:num) |> String
end 

reply(::Type{redisreply{:(:)}}, value::AbstractString, conn::TCPSocket) = parse(Int, value) 
reply(::Type{redisreply{:+}}, value::AbstractString, conn::TCPSocket)   = value
reply(::Type{redisreply{:-}}, value::AbstractString, conn::TCPSocket)   = throw(value)
reply(conn::TCPSocket , num::Int) = num >=1 ? reply(redisreply{:*}, string(num), conn) : nothing

# 输入redis 命令拼接函数
execute_send(conn::RedisConnectionBase, command::AbstractVector) = send_command(conn, pack_command(command))
execute_send(conn::RedisConnectionBase, command::AbstractString) = send_command(conn, command)

@inline function execute_reply(conn::RedisConnectionBase, command::AbstractVector)
    execute_send(conn, command)
    reply(conn.socket)
end 

function pack_command(command::AbstractVector)
    packed_command = "*$(length(command))\r\n"
    for token in command
        packed_command = string(packed_command, "\$$(length(token))\r\n", token, "\r\n")
    end
    packed_command
end

Merge_parameters(command...) = vcat(map(Merge_parameter, command)...)::Vector{String}

Merge_parameter(token::Symbol) = string(token)
Merge_parameter(token::Number) = string(token)
Merge_parameter(token::AbstractString) = token
Merge_parameter(token::Vector)  = map(Merge_parameter, token)::Vector{String}
Merge_parameter(token::Set) = json(token)
Merge_parameter(token::Dict) = json(token)
Merge_parameter(token::Tuple)  = json(token)

# 生成函数 宏

extra(d::Expr) = d.head == :(::) ? d.args[1] : d 
extra(d::Symbol) = d
extra(d::AbstractString) = d 

function genfunction(  kw::Vector ) 

    func = Expr(:call , Symbol(kw[1]) ,Expr(:(::) , :conn , :RedisConnection))
    func1 = Expr(:call , Symbol(kw[1]))

    length(kw) > 1 && begin 
                        append!(func.args, kw[2:end] )
                        append!(func1.args, kw[2:end] )
                        end 
    tmp = [ extra(i) for i in kw ]  

    block = Expr(:block , Expr(:call, :execute_reply, :conn, Expr(:call, :Merge_parameters ,tmp... )) )
    block1 = Expr(:block ,  Expr(:call, :pack_command , Expr(:call, :Merge_parameters ,tmp... ) ))

   esc(Expr(:block , Expr(:function , func, block), Expr(:function , func1, block1)))

end 

macro genfunction( kw... )
     genfunction( collect(kw) ) 
end 

function pipe_trans(conn::RedisConnectionBase, comms::Vector{ <: AbstractString}, num::Int)
     execute_send(conn, join(comms) )  
     reply(conn.socket, num )
end 

function pipe_trans(conn::RedisConnectionBase, comms::AbstractString, num::Int)
     execute_send(conn, comms  )  
     reply(conn.socket, num )
end 

pipelines(conn::RedisConnectionBase, fun... ) = pipe_trans(conn, collect(fun), length(collect(fun)))
pipelines(conn::RedisConnectionBase, fun::AbstractString, num::Int ) = pipe_trans(conn, fun,  num )

function transactions(conn::RedisConnectionBase, fun... ) 
     comms = [multi(), collect(fun)..., exec()]
     pipe_trans(conn, comms, length(comms))
end 

function transactions(conn::RedisConnectionBase, fun::AbstractString, num::Int ) 
     comms = join[multi(), fun , exec()]
     pipe_trans(conn, comms, num )
end 

Mytype = Union{Symbol , Expr}

function rep_func(a::Mytype , b::Mytype)
    
    tpe  = a.head == :(::) ? a.args[2] : :AbstractString 
    ab ,aa = extra(b), extra(a)
    
    func = Expr(:call , :rep , a, b )
    b1   = Expr(:(=), :res , Expr(:call , Expr(:curly, :Vector , tpe) , :undef, ab) )
    b2   = Expr(:macrocall, Symbol("@inbounds"), "",
                    Expr(:for , Expr(:(=), :i , Expr(:call, :(:), 1, ab ) ),
                       Expr(:block, Expr(:(=) , Expr(:ref, :res, :i) , aa ) ) ))
        
    Expr(:function , func, Expr(:block,  b1, b2, :res) ) 
    
end 

macro rep(a, b )
   esc(rep_func(a,b))
end 
      
@rep(data::Dict, num::Integer)
@rep(data::Number, num::Integer)
@rep(data::Tuple, num::Integer)
@rep(data::AbstractString, num::Integer)
@rep(data::AbstractArray, num::Integer)
@rep(data::AbstractChar, num::Integer)

