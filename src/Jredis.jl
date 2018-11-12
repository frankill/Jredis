__precompile__()

module Jredis
    
    using Sockets 

    # Connection commands
    export auth, echo, ping, quit, select
    # list commands
    export blpop, brpop, brpoplpush, lindex, linsert, llen,
           lpop, lpush, lpushx, lrange, lrem, lset,
           ltrim, rpop, rpoplpush, rpush, rpushx

    include("connection.jl") 
    include("redis.jl")
    include("commands.jl")
end 
