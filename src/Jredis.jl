__precompile__()

module Jredis
    
    using Sockets 
    import JSON.json
    
    export RedisConnection
    # Connection commands
    export auth, echo, ping, quit, select
    # list commands
    export blpop, brpop, brpoplpush, lindex, linsert, llen,
           lpop, lpush, lpushx, lrange, lrem, lset,
           ltrim, rpop, rpoplpush, rpush, rpushx

    abstract type RedisConnectionBase end
    abstract type SubscribableConnection<:RedisConnectionBase end 

    mutable struct RedisConnection <: SubscribableConnection
        host::AbstractString
        port::Integer
        password::AbstractString
        db::Integer
        socket::TCPSocket
    end

    function RedisConnection(; host="127.0.0.1", port=6379, password= nothing, db=0)
        try
            socket = connect(host, port)
            connection = RedisConnection(host, port, password, db, socket)
            on_connect(connection)
        catch
            throw("Failed to connect to Redis server")
        end
    end

    function on_connect(conn::RedisConnectionBase)
        conn.password != nothing && auth(conn, conn.password)
        conn.db != 0             && select(conn, conn.db)
        conn
    end

    disconnect(conn::RedisConnectionBase) = close(conn.socket)
    is_connected(conn::RedisConnectionBase) =conn.socket.status in [8 ,3 ]
    send_command(conn::RedisConnectionBase, command::AbstractString) =write(conn.socket, command)


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
    reply(::Type{redisreply{:-}}, value::AbstractString, conn::TCPSocket)   = throw(value)

    # 输入redis 命令拼接函数
    function execute_reply(conn::RedisConnectionBase, command::AbstractVector)

        is_connected(conn) || throw(ConnectionException("Socket is disconnected"))
        send_command(conn, pack_command(command))
        reply(conn.socket)

    end 

    function pack_command(command::AbstractVector)
        packed_command = "*$(length(command))\r\n"
        for token in command
            ltoken = ifelse( isa(token, Number) , length(string(token)), length(token))
            packed_command = string(packed_command, "\$$(ltoken)\r\n", token, "\r\n")
        end
        packed_command
    end

    Merge_parameters(command...) = map(Merge_parameter, command)

    Merge_parameter(token) = string(token)
    Merge_parameter(token::AbstractString) = token
    Merge_parameter(token::Array) = map(Merge_parameter, token)
    Merge_parameter(token::Set) = json(token)
    Merge_parameter(token::Dict) = json(token)
    Merge_parameter(token::Tuple)  = json(token)

    # 生成函数 宏

    extra(d::Expr) = d.head == :(::) ? d.args[1] : d 
    extra(d::Symbol) = d 

    function genfunction(  kw::Vector  ) 

        func = Expr(:call , 
            kw[1] ,
            Expr(:(::) , :conn , :RedisConnectionBase)
            )

        length(kw) > 1 && append!(func.args, kw[2:end] )
        tmp = [ extra(i) for i in kw ]  

        block = Expr(:block , Expr(:call, :execute_reply, :conn, 
                                    Expr(:call, :Merge_parameters ,tmp... )) )

        esc( Expr(:function , func, block) )

    end 

    macro genfunction( kw... )

         genfunction( collect(kw) ) 

    end 

    # 生成函数list

    @redisfunction auth password
    @redisfunction echo  message
    @redisfunction ping 
    @redisfunction quit 
    @redisfunction select  index
    # Key commands

    @redisfunction del  key...
    @redisfunction exists key
    @redisfunction expire key seconds
    @redisfunction expireat key timestamp
    @redisfunction migrate host port key destinationdb timeout
    @redisfunction move key db
    @redisfunction persist key
    @redisfunction pexpire key milliseconds
    @redisfunction pexpireat key millisecondstimestamp
    @redisfunction pttl key
    @redisfunction randomkey
    @redisfunction rename key newkey
    @redisfunction renamenx key newkey
    @redisfunction restore key ttl serializedvalue
    @redisfunction scan cursor::Integer options...
    @redisfunction ttl key

    # List commands
    @redisfunction blpop keys timeout
    @redisfunction brpop keys timeout
    @redisfunction brpoplpush source destination timeout
    @redisfunction lindex key index
    @redisfunction linsert key place pivot value
    @redisfunction llen key
    @redisfunction lpop key
    @redisfunction lpush key value values...
    @redisfunction lpushx key value
    @redisfunction lrange key start finish
    @redisfunction lrem key count value
    @redisfunction lset key index value
    @redisfunction ltrim key start finish
    @redisfunction rpop key
    @redisfunction rpoplpush source destination
    @redisfunction rpush key value values...
    @redisfunction rpushx key value

end 
