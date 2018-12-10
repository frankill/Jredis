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
    
    con = esc(conn)
    quote
        try 
            ping( $con ) 
        catch
            reline( $con , ftime())
        end  
    end
end 

macro lpop(redis, key ,fun, batch)

    nums = Expr(:(=), :num , Expr(:call, :(|>), 
                Expr(:call, :llen, redis, key) , 
                Expr(:(->), :q, Expr(:block, 
                    Expr(:if , Expr(:call, :(>=), :q, batch) ,
                        batch , :q)))))
    
    expr = Expr(:call, :pipelines, redis, 
            Expr(:(...), Expr(:call, :rep , Expr(:call, :lpop , key) ,:num))) 

    esc( Expr(:block, 
        Expr(:(=), :freq, Expr(:call, :ftime)),
        Expr(:while , true, 
            Expr(:block, :(@cheak_reline $redis), nums ,
            Expr(:if , Expr(:call, :(>=), :num ,1), 
                                Expr(:block, Expr(:call, :(|>), expr, fun ), Expr(:call, :finit, :freq )),
                                Expr(:block, Expr(:if , Expr(:call, :(>=), Expr(:(.) , :freq, :(:t)), 3600),
                                                            Expr(:call, :sleep, 3600), 
                                                            Expr(:call, :sleep, Expr(:call, :fadd, :freq)) 
                                                             )))))))
end  
 
 
