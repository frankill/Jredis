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
const TIMES = 2
mutable struct Ftime 
    t::Int
end
ftime() = Ftime(TIMES) 
@inline fadd(t::Ftime) = t.t += TIMES
@inline finit(t::Ftime) = t.t > TIMES && (t.t= TIMES)

function monitoring(redis::RedisConnection, key::Union{AbstractString,Symbol} ,fun::Function, batch::Int = 250)

    freq = ftime()
    no_line = ftime()

    while true

        if ! (is_connected(redis)) 
            println("Failed to connect to Redis server Reconnect ")
            sleep(fadd(no_line))
            try 
                redis = RedisConnection(redis) 
            finally 
                continue
            end 
        else 
            finit(no_line)
        end 
        
        try
            num= llen(redis, key) |> q -> q >= batch ? batch : q 
        catch 
            continue
        end 
        
        if  num >= 1     
            pipelines(redis, rep(lpop(key), num )...) |> fun
            finit(freq)
        else 
            if freq.t >= 3600 
                sleep(3600)
            else 
                sleep(fadd(freq))
            end  
        end 
    end 

end 

monitoring( conn , "frank" , q -> println(q, "\n") )

```
