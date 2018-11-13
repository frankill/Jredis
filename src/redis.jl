
"""
Formatting of outgoing commands to the Redis server
"""
function pack_command(command)
    packed_command = "*$(length(command))\r\n"
    for token in command
        ltoken = ifelse(typeof(token) <: Number, length(string(token)), length(token))
        packed_command = string(packed_command, "\$$(ltoken)\r\n", token, "\r\n")
    end
    packed_command
end

function execute_command_without_reply(conn::RedisConnectionBase, command)
    is_connected(conn) || throw(ConnectionException("Socket is disconnected"))
    send_command(conn, pack_command(command))
end

function execute_command(conn::RedisConnectionBase, command)
    execute_command_without_reply(conn, command)
    reply(conn.socket)
end

struct redisreply{T} end 

function reply(conn::TCPSocket)
    tmp = readline(conn)
    syms, value = tmp[1] , tmp[2:end]
    reply(redisreply{Symbol(syms)}, value, conn)
end 

function reply(::Type{redisreply{:*}}, value::AbstractString, conn::TCPSocket) 
    num = parse(Int, value)
    num == -1 && return nothing 
    num == 0 && return []
    res = Vector(undef, num)
    for i in 1:num
        res[i] = reply(conn)
    end 
    return res 
end 

function reply(::Type{redisreply{:$}}, value::AbstractString, conn::TCPSocket)
    num = parse(Int, value)
    num == -1 ? nothing : readline(conn)
end 

reply(::Type{redisreply{:(:)}}, value::AbstractString, conn::TCPSocket) = parse(Int, value) 
reply(::Type{redisreply{:+}}, value::AbstractString, conn::TCPSocket)   = value
reply(::Type{redisreply{:-}}, value::AbstractString, conn::TCPSocket)   = throw(ProtocolException(value))

flatten_command(command...) = vcat(map(flatten, command)...)

flatten(token) = string(token)
flatten(token::AbstractString) = token
flatten(token::Array) = map(string, token)
flatten(token::Set) = map(string, collect(token))
function flatten(token::Dict)
    r=AbstractString[]
    for (k,v) in token
        push!(r, string(k))
        push!(r, string(v))
    end
    r
end
function flatten(token::Tuple{T, U}) where T<:Number  where U<:AbstractString 
    r=[]
    for item in token
        push!(r, item[1])
        push!(r, item[2])
    end
    r
end 

macro redisfunction(command::AbstractString, ret_type, args...)
    func_name = esc(Symbol(command))
    command = lstrip(command,'_')
    command = split(command, '_')


    if length(args) > 0
        return quote
            function $(func_name)(conn::RedisConnection, $(args...))
                response = execute_command(conn, flatten_command($(command...), $(args...)))
                response
            end
        end
    else
        return quote
            function $(func_name)(conn::RedisConnection)
                response = execute_command(conn, flatten_command($(command...)))
                response
            end
        end
    end
end



abstract type RedisException <:Exception end
mutable struct  ConnectionException <: RedisException
    message::AbstractString
end

mutable struct ProtocolException <: RedisException
    message::AbstractString
end

mutable struct ServerException <: RedisException
    message::AbstractString
end

mutable struct ClientException <: RedisException
    message::AbstractString
end
