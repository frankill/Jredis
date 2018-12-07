    abstract type RedisConnectionBase end
    abstract type SubscribableConnection<:RedisConnectionBase end 

    mutable struct RedisConnection <: SubscribableConnection
        host::AbstractString
        port::Integer
        password::AbstractString
        db::Integer
        socket::TCPSocket
    end

    mutable struct PipelineConnection <: RedisConnectionBase
        host::AbstractString
        port::Integer
        password::AbstractString
        db::Integer
        socket::TCPSocket
        num_commands::Integer
    end

    function PipelineConnection(parent::RedisConnection)
        try
            socket = connect(parent.host, parent.port)
            pipeline_connection = PipelineConnection(parent.host,
                parent.port, parent.password, parent.db, socket, 0)
            on_connect(pipeline_connection)
        catch
            throw(ConnectionException("Failed to create pipeline"))
        end
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

    function on_connect(conn::RedisConnectionBase)
        conn.password != "" && auth(conn, conn.password)
        conn.db != 0        && select(conn, conn.db)
        conn
    end

    disconnect(conn::RedisConnectionBase) = close(conn.socket)
    is_connected(conn::RedisConnectionBase) =conn.socket.status in [8 ,3]
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
    read_pipeline(conn::PipelineConnection) = conn.num_commands >=1 && reply(redisreply{:*}, string(conn.num_commands), conn.socket)


    # 输入redis 命令拼接函数
    function execute_send(conn::RedisConnectionBase, command::AbstractVector)
        is_connected(conn) || throw(ConnectionException("Socket is disconnected"))
        send_command(conn, pack_command(command))
    end 

    function execute_reply(conn::RedisConnectionBase, command::AbstractVector)
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

    Merge_parameters(command...) = vcat(map(Merge_parameter, command)...)

    Merge_parameter(token) = string(token)
    Merge_parameter(token::AbstractString) = token
    Merge_parameter(token::Array) = map(Merge_parameter, token)
    Merge_parameter(token::Set) = json(token)
    Merge_parameter(token::Dict) = json(token)
    Merge_parameter(token::Tuple)  = json(token)

    # 生成函数 宏

    extra(d::Expr) = d.head == :(::) ? d.args[1] : d 
    extra(d::Symbol) = d
    extra(d::AbstractString) = d 

    function genfunction(  kw::Vector  ) 

        func = Expr(:call , Symbol(kw[1]) ,Expr(:(::) , :conn , :RedisConnection))
        func1 = Expr(:call , Symbol(kw[1]) ,Expr(:(::) , :conn , :PipelineConnection))

        length(kw) > 1 && begin 
                            append!(func.args, kw[2:end] )
                            append!(func1.args, kw[2:end] )
                            end 
        tmp = [ extra(i) for i in kw ]  
    
        block = Expr(:block , Expr(:call, :execute_reply, :conn, Expr(:call, :Merge_parameters ,tmp... )) )
        block1 = Expr(:block , 
                                Expr(:call, :execute_send, :conn, Expr(:call, :Merge_parameters ,tmp... )) ,
                                       Expr(:(+=) , Expr(:(.), :conn,  :(:num_commands))  , 1 )   )

       esc(Expr(:block , Expr(:function , func, block), Expr(:function , func1, block1)))

    end 

    macro genfunction( kw... )

         genfunction( collect(kw) ) 

    end 
