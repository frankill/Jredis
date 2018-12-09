redis Client implemented in Julia.  Partial features of Redis

```julia

conn = RedisConnection()

Dict( "frank" => 1, "test" => "frank") |> 
    q -> lpush(conn, :frank , rep(q, 100000) )
    
llen(conn, :frank)
lpop(conn, :frank)

pipelines(conn, rep(lpop(:frank) , llen(conn, :frank) )...)

```
