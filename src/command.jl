
# 生成函数list



@genfunction "auth" password
@genfunction "echo"  message
@genfunction "ping" 
@genfunction "quit" 
@genfunction "select"  index::Int
# Key commands
@genfunction "keys" pattern
@genfunction "del" key...
@genfunction "exists" key
@genfunction "expire" key seconds
@genfunction "expireat" key timestamp
@genfunction "migrate" host port key destinationdb timeout
@genfunction "move" key db::Int
@genfunction "persist" key
@genfunction "pexpire" key milliseconds::Int
@genfunction "pexpireat" key millisecondstimestamp::Int
@genfunction "pttl" key
@genfunction "randomkey"
@genfunction "rename" key newkey
@genfunction "renamenx" key newkey
@genfunction "restore" key ttl::Int seIntegerrializedvalue
@genfunction "scan" cursor::Int options...
@genfunction "ttl" key

# List commands
@genfunction "blpop" keys timeout::Int
@genfunction "brpop" keys timeou::Int
@genfunction "brpoplpush" source destination timeout::Int
@genfunction "lindex" key index
@genfunction "linsert" key place pivot value
@genfunction "llen" key
@genfunction "lpop" key
@genfunction "lpush" key value
@genfunction "lpush" key values...
@genfunction "lpushx" key value
@genfunction "lrange" key start::Int stop::Int
@genfunction "lrem" key count::Int value
@genfunction "lset" key index value
@genfunction "ltrim" key start::Int stop::Int
@genfunction "rpop" key
@genfunction "rpoplpush" source destination
@genfunction "rpush" key value
@genfunction "rpush" key values...    
@genfunction "rpushx" key value

# string 
@genfunction "append" key value
@genfunction "bitcount" key options...
@genfunction "bitcount" key
@genfunction "bitop" operation destkey keys...
@genfunction "bitop" operation destkey key
@genfunction "decr" key
@genfunction "decrby" key decrement
@genfunction "get" key
@genfunction "getbit" key offset
@genfunction "getrange" key start finish
@genfunction "getset" key value
@genfunction "incr" key
@genfunction "incrby" key increment::Integer
@genfunction "incrbyfloat" key increment::Float64
@genfunction "mget" keys...
@genfunction "mget" key
@genfunction "mset" keyvalues
@genfunction "msetnx" keyvalues
@genfunction "psetex" key milliseconds value
@genfunction "set" key value options...
@genfunction "setbit" key offset value
@genfunction "setex" key seconds value
@genfunction "setnx" key value
@genfunction "setrange" key offset value
@genfunction "strlen" key

# Hash commands
@genfunction "hdel" key field fields...
@genfunction "hexists" key field
@genfunction "hget" key field
@genfunction "hgetall" key
@genfunction "hincrby" key field increment::Integer
@genfunction "hincrbyfloat" key field increment::Float64
@genfunction "hkeys" key
@genfunction "hlen" key
@genfunction "hmget" key field fields...
@genfunction "hmget" key field
@genfunction "hmset" key value
@genfunction "hset" key field value
@genfunction "hsetnx" key field value
@genfunction "hvals" key
@genfunction "hscan" key cursor::Integer options...

# Set commands
@genfunction "sadd" key members...
@genfunction "sadd" key member
@genfunction "scard" key
@genfunction "sdiff" keys...
@genfunction "sdiff" key
@genfunction "sdiffstore" destination key keys...
@genfunction "sdiffstore" destination key
@genfunction "sinter" keys...
@genfunction "sinter" key
@genfunction "sinterstore" destination key keys...
@genfunction "sinterstore" destination key
@genfunction "sismember" key member
@genfunction "smembers" key
@genfunction "smove" source destination member
@genfunction "spop" key
@genfunction "srandmember" key
@genfunction "srandmember" key count
@genfunction "srem" key members...
@genfunction "srem" key member
@genfunction "sunion" key keys...
@genfunction "sunion" key
@genfunction "sunionstore" destination key keys...
@genfunction "sunionstore" destination key
@genfunction "sscan"  key cursor::Integer options...

# Sorted set commands
@genfunction "zadd" key score::Number member::AbstractString
@genfunction "zadd" key scoreMemberZip...
@genfunction "zcard" key
@genfunction "zcount" key min max
@genfunction "zincrby" key increment member
@genfunction "zlexcount" key min max
@genfunction "zrange"  key start stop options...
@genfunction "zrange"  key start stop
@genfunction "zrangebyscore"  key min max options...
@genfunction "zrangebyscore"  key min max
@genfunction "zrank" key member
@genfunction "zrem" key members...
@genfunction "zrem" key member
@genfunction "zremrangebylex" key min max
@genfunction "zremrangebyrank" key start stop
@genfunction "zremrangebyscore" key start stop
@genfunction "zrevrange" key start stop options...
@genfunction "zrevrangebyscore"  key start stop options...
@genfunction "zrevrank" key member
@genfunction "zscore" key member
@genfunction "zscan" key cursor::Integer options...


# HyperLogLog commands
@genfunction "pfadd" key elements...
@genfunction "pfadd" key element
@genfunction "pfcount" keys...
@genfunction "pfcount" key
@genfunction "pfmerge" destkey sourcekey sourcekeys...

# Transaction commands
@genfunction "discard"
@genfunction "exec" 
@genfunction "multi" 
@genfunction "unwatch" 
@genfunction "watch"  keys...
@genfunction "watch"  key

#################################################################
# TODO: NEED TO TEST BEYOND THIS POINT
@genfunction "evalsha" sha1 numkeys keys args
@genfunction "script_exists" script scripts...
@genfunction "script_flush"
@genfunction "script_kill"
@genfunction "script_load" script

# Server commands
@genfunction "bgrewriteaof"
@genfunction "bgsave"
@genfunction "client_getname"
@genfunction "client_list" 
@genfunction "client_pause" timeout
@genfunction "client_setname" name
@genfunction "cluster_slots"
@genfunction "command"
@genfunction "command_count"
@genfunction "command_info" command commands...
@genfunction "command_info" commands...
@genfunction "config_get" parameter
@genfunction "config_resetstat"
@genfunction "config_rewrite"
@genfunction "config_set" parameter value
@genfunction "dbsize"
@genfunction "debug_object" key
@genfunction "debug_segfault"
@genfunction "flushall"
@genfunction "flushdb"
@genfunction "info"
@genfunction "info" section
@genfunction "lastsave"
@genfunction "role"
@genfunction "save"
@genfunction "shutdown"
@genfunction "shutdown" option
@genfunction "slaveof" host port
@genfunction "time"

