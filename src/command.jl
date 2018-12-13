
# 生成函数list

Pamtype = Union{Symbol, AbstractString, Number}

@genfunction "auth" password::Pamtype
@genfunction "echo"  message::Pamtype
@genfunction "ping" 
@genfunction "quit" 
@genfunction "select"  index::Int
# Key commands
@genfunction "keys" pattern::Pamtype
@genfunction "del" key...
@genfunction "exists" key::Pamtype
@genfunction "expire" key::Pamtype seconds
@genfunction "expireat" key::Pamtype timestamp
@genfunction "migrate" host::Pamtype port::Pamtype key::Pamtype destinationdb timeout
@genfunction "move" key::Pamtype db::Int
@genfunction "persist" key::Pamtype
@genfunction "pexpire" key::Pamtype milliseconds::Int
@genfunction "pexpireat" key::Pamtype millisecondstimestamp::Int
@genfunction "pttl" key::Pamtype
@genfunction "randomkey"
@genfunction "rename" key::Pamtype newkey::Pamtype
@genfunction "renamenx" key::Pamtype newkey::Pamtype
@genfunction "restore" key::Pamtype ttl::Int seIntegerrializedvalue
@genfunction "scan" cursor::Int options...
@genfunction "ttl" key::Pamtype

# List commands
@genfunction "blpop" keys::Pamtype timeout::Int
@genfunction "brpop" keys::Pamtype timeou::Int
@genfunction "brpoplpush" source::Pamtype destination::Pamtype timeout::Int
@genfunction "lindex" key::Pamtype index::Pamtype
@genfunction "linsert" key::Pamtype place::Pamtype pivot::Pamtype value::Pamtype
@genfunction "llen" key::Pamtype
@genfunction "lpop" key::Pamtype
@genfunction "lpush" key::Pamtype value::Pamtype
@genfunction "lpush" key::Pamtype values...
@genfunction "lpushx" key::Pamtype value::Pamtype
@genfunction "lrange" key::Pamtype start::Int stop::Int
@genfunction "lrem" key::Pamtype count::Int value::Pamtype
@genfunction "lset" key::Pamtype index::Pamtype value::Pamtype
@genfunction "ltrim" key::Pamtype start::Int stop::Int
@genfunction "rpop" key::Pamtype
@genfunction "rpoplpush" source::Pamtype destination::Pamtype
@genfunction "rpush" key::Pamtype value::Pamtype
@genfunction "rpush" key::Pamtype values...    
@genfunction "rpushx" key::Pamtype value::Pamtype

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

