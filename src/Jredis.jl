__precompile__()

module Jredis
    
    using Sockets 
    import JSON.json
    
    export RedisConnection
    # Key commands
    export del,  exists, expire, expireat,
           migrate, move, persist, pexpire, pexpireat,
           pttl, randomkey, rename, renamenx, restore,
           scan, ttl
    # String commands
    export append, bitcount, bitop, decr, decrby,
            getbit, getrange, getset, incr, incrby,
           incrbyfloat, mget, mset, msetnx, psetex, set,
           setbit, setex, setnx, setrange, strlen
    # Hash commands
    export hdel, hexists, hget, hgetall, hincrby, hincrbyfloat,
           hkeys, hlen, hmget, hmset, hset, hsetnx, hvals,
           hscan
    # List commands
    export blpop, brpop, brpoplpush, lindex, linsert, llen,
           lpop, lpush, lpushx, lrange, lrem, lset,
           ltrim, rpop, rpoplpush, rpush, rpushx
    # Set commands
    export sadd, scard, sdiff, sdiffstore, sinter, sinterstore,
           sismember, smembers, smove, spop, srandmember, srem,
           sunion, sunionstore, sscan
    # Sorted set commands
    export zadd, zcard, zcount, zincrby, zinterstore, zlexcount,
           zrange, zrangebylex, zrangebyscore, zrank, zrem,
           zremrangebylex, zremrangebyrank, zremrangebyscore, zrevrange,
           zrevrangebyscore, zrevrank, zscore, zunionstore, zscan
    # HyperLogLog commands
    export pfadd, pfcount, pfmerge
    # Connection commands
    export auth, echo, ping, quit, select
    # Transaction commands
    export discard, exec, multi, unwatch, watch
    # Scripting commands
    export evalscript, evalsha, script_exists, script_flush, script_kill, script_load
    # PubSub commands
    export subscribe, publish, psubscribe, punsubscribe, unsubscribe
    # Server commands
    export bgrewriteaof, bgsave, client_list, client_pause, client_setname, cluster_slots,
           command, command_count, command_info, config_get, config_resetstat, config_rewrite,
           config_set, dbsize, debug_object, debug_segfault, flushall, flushdb, info, lastsave,
           role, save, shutdown, slaveof


 
    include("api.jl")
    include("command.jl")
end 
