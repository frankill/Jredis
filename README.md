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

fun(x) = parse.(Int, x) |> println
@lpop conn :frank fun 250 

```
