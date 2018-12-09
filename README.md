redis Client implemented in Julia.  Partial features of Redis

```julia

conn = RedisConnection()

# 批量插入10000條數據
Dict( "frank" => 1, "test" => "frank") |> 
    q -> lpush(conn, :frank , rep(q, 10000) )
    
llen(conn, :frank)
lpop(conn, :frank)

# 管道獲取所有剩餘對象
pipelines(conn, rep(lpop(:frank) , llen(conn, :frank) )...)

```
