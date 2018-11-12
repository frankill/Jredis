using Sockets 

abstract type RedisConnectionBase end
abstract type SubscribableConnection<:RedisConnectionBase end 


mutable struct RedisConnection <: SubscribableConnection
    host::AbstractString
    port::Integer
    password::AbstractString
    db::Integer
    socket::TCPSocket
end

function RedisConnection(; host="127.0.0.1", port=6379, password="", db=0)
    try
        socket = connect(host, port)
        connection = RedisConnection(host, port, password, db, socket)
        on_connect(connection)
    catch
        throw(ConnectionException("Failed to connect to Redis server"))
    end
end

function on_connect(conn::RedisConnectionBase)
    conn.password != "" && auth(conn, conn.password)
    conn.db != 0        && select(conn, conn.db)
    conn
end

function disconnect(conn::RedisConnectionBase)
    close(conn.socket)
end

function is_connected(conn::RedisConnectionBase)
    conn.socket.status == StatusActive || conn.socket.status == StatusOpen || conn.socket.status == StatusPaused
end

function send_command(conn::RedisConnectionBase, command::AbstractString)
    write(conn.socket, command)
end

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
    #is_connected(conn) || throw(ConnectionException("Socket is disconnected"))
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
    num == -1 && return missing 
    num == 0 && return []
    res = Array{any,1}(undef, num)
    for i in 1:num
        res[i] = reply(conn)
    end 
    return res 
end 

reply(::Type{redisreply{:$}}, value::AbstractString, conn::TCPSocket)   = readline(conn)
reply(::Type{redisreply{:(:)}}, value::AbstractString, conn::TCPSocket) = parse(Int, value) 
reply(::Type{redisreply{:+}}, value::AbstractString, conn::TCPSocket)   = value
reply(::Type{redisreply{:-}}, value::AbstractString, conn::TCPSocket)   =throw(ProtocolException(value))

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

@redisfunction "auth" AbstractString password
@redisfunction "echo" AbstractString message
@redisfunction "ping" AbstractString
@redisfunction "quit" Bool
@redisfunction "select" AbstractString index
# Key commands
@redisfunction "del" Integer key...
#@redisfunction "dump" AbstractString key
@redisfunction "exists" Bool key
@redisfunction "expire" Bool key seconds
@redisfunction "expireat" Bool key timestamp
#@redisfunction "keys" Set{AbstractString} pattern
@redisfunction "migrate" Bool host port key destinationdb timeout
@redisfunction "move" Bool key db
@redisfunction "persist" Bool key
@redisfunction "pexpire" Bool key milliseconds
@redisfunction "pexpireat" Bool key millisecondstimestamp
@redisfunction "pttl" Integer key
@redisfunction "randomkey" Union{AbstractString, Missing}
@redisfunction "rename" AbstractString key newkey
@redisfunction "renamenx" Bool key newkey
@redisfunction "restore" Bool key ttl serializedvalue
@redisfunction "scan" Array{AbstractString, 1} cursor::Integer options...
#@redisfunction "sort" Array{AbstractString, 1} key options...
@redisfunction "ttl" Integer key
# List commands
@redisfunction "blpop" Array{AbstractString, 1} keys timeout
@redisfunction "brpop" Array{AbstractString, 1} keys timeout
@redisfunction "brpoplpush" AbstractString source destination timeout
@redisfunction "lindex" Union{AbstractString, Missing} key index
@redisfunction "linsert" Integer key place pivot value
@redisfunction "llen" Integer key
@redisfunction "lpop" Union{AbstractString, Missing} key
@redisfunction "lpush" Integer key value values...
@redisfunction "lpushx" Integer key value
@redisfunction "lrange" Array{AbstractString, 1} key start finish
@redisfunction "lrem" Integer key count value
@redisfunction "lset" AbstractString key index value
@redisfunction "ltrim" AbstractString key start finish
@redisfunction "rpop" Union{AbstractString, Missing} key
@redisfunction "rpoplpush" Union{AbstractString, Missing} source destination
@redisfunction "rpush" Integer key value values...
@redisfunction "rpushx" Integer key value

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


 redis = RedisConnection()
 select(redis, 9)
lindex(redis , "test" ,4)
