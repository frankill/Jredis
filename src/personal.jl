const TIMES = 2
mutable struct Ftime 
    t::Int
end

@inline ftime() = Ftime(TIMES) 
@inline fadd(t::Ftime) = t.t += TIMES
@inline finit(t::Ftime) = t.t > TIMES && (t.t= TIMES)

function reline(conn::RedisConnectionBase, times::Ftime) 
    sleep(times.t)
    try 
        reconnect(conn)
    catch
        fadd(times)
        reline(conn, times)
    end
  
end 

macro cheak_reline(conn )
    quote
        try 
            ping($conn) 
        catch
            reline($conn, ftime())
        end  
    end
end 
 
