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
