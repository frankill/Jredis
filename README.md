redis Client implemented in Julia.  Partial features of Redis

```julia

using Jredis
conn = RedisConnection()

# Batch insertion of 10,000 pieces of data
Dict( "frank" => 1, "test" => "frank") |> 
    q -> lpush(conn, :frank , rep(q, 10000) )
    
llen(conn, :frank)
lpop(conn, :frank)

# Batch Return of Remaining Data
pipelines(conn, rep(lpop(:frank) , llen(conn, :frank) )...)


# 监控key并批量返回
const TIMES = 2
mutable struct Ftime 
    t::Int
end
ftime() = Ftime(TIMES) 
@inline fadd(t::Ftime) = t.t += TIMES
@inline finit(t::Ftime) = t.t > TIMES && (t.t= TIMES)

function monitoring(redis::RedisConnection, key::AbstractString ,batch::Int = 250 )

    freq = ftime()

    while true

        if ! (Jredis.is_connected(redis)) 
            println("Failed to connect to Redis server Reconnect ")
            sleep(10)
            redis = RedisConnection(redis)
        end 

        num = llen(redis, key) |> q -> q >= batch ? batch : q 

        if  num >= 1     
            pipelines(redis, rep(lpop(key), num )...) |> q -> println( q , "\n")
            finit(freq)
        else 
            sleep(fadd(freq)) 
        end 
    end 

end 

monitoring( RedisConnection() , "frank")

```
