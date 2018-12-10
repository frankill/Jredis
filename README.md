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
pipelines(conn, rep(lpop(:frank) , 100 )...)

# monitoring key return data

function monitoring(redis::RedisConnection, key::Union{AbstractString,Symbol} ,fun::Function, batch::Int = 250)

    while true

        @cheak_reline redis 
        num= llen(redis, key) |> q -> q >= batch ? batch : q 
        pipelines(redis, rep(lpop(key), num )...) |> fun
        
    end 

end 

monitoring( conn , "frank" , q -> println(q, "\n") )

```
