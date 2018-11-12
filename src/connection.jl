

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
