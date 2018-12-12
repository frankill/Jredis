const TIMES = 2
mutable struct Ftime 
    t::Int
end

@inline ftime() = Ftime(TIMES) 
@inline fadd(t::Ftime) = t.t += TIMES
@inline finit(t::Ftime) = t.t > TIMES && (t.t= TIMES)

function reline(conn::RedisConnectionBase, times::Ftime) 
    println("Failed to connect to Redis server ,Reconnect after $(times.t) seconds .")
    sleep(times.t)
    try 
        reconnect(conn)
        println("Success to connect to Redis server , Time consuming greater than or equal to
$(times.t) sec. .")
    catch
        times.t >= 600 || fadd(times)
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
 
macro genmacro(funname, lenfun, popfun)

    func = Expr(:call , funname, :redis,  :key ,:fun, :batch )

    nums = Expr(:(=), :num , Expr(:call, :(|>), 
                Expr(:call, lenfun, Expr(:$, :redis), Expr(:$, :key)) , 
                Expr(:(->), :q, Expr(:block, 
                    Expr(:if , Expr(:call, :(>=), :q, Expr(:$, :batch)) ,
                        Expr(:$, :batch) , :q)))))
    
    expr = Expr(:call, :pipelines, Expr(:$, :redis), 
            Expr(:(...), Expr(:call, :rep , Expr(:call, popfun , Expr(:$, :key)) ,:num))) 

    body =  Expr(:block, 
        Expr(:(=), :freq, Expr(:call, :ftime)),
        Expr(:while , true, 
            Expr(:block, Expr(:macrocall, Symbol("@cheak_reline"), "", Expr(:$, :redis)) , nums ,
            Expr(:if , Expr(:call, :(>=), :num ,1), 
                                Expr(:block, Expr(:call, :(|>), expr, Expr(:$, :fun)), Expr(:call, :finit, :freq )),
                                Expr(:block, Expr(:if , Expr(:call, :(>=), Expr(:(.) , :freq, :(:t)), 600),
                                                            Expr(:call, :sleep, 600), 
                                                            Expr(:call, :sleep, Expr(:call, :fadd, :freq)) 
                                                             ))))))

     esc( Expr( :macro , func,   Expr(:block, Expr(:call, :esc,Expr(:quote, body)))))   

end 

@genmacro spop scard spop
@genmacro lpop llen lpop
@genmacro rpop llen rpop

