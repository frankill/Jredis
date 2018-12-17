const TIMES = 2
const sym = ["\$", "+", "-", ":" , "*"]
mutable struct Ftime 
    t::Int
end

@inline ftime() = Ftime(TIMES) 
@inline fadd(t::Ftime) = t.t += TIMES
@inline finit(t::Ftime) = t.t > TIMES && (t.t= TIMES)

function redis_collect(conn::RedisConnection , data::Vector = [])

	res = @async eof(conn.socket)  
    	println(res.state) 
	if res.state == :done   
		tmp = readline(conn.socket)  
		syms, value = tmp[1] , tmp[2:end]

		if ! (syms in sym) 
		    push!(data, tmp)
		else 
		    push!(data, reply( conn.socket  ) 
		end 

		redis_collect(conn, data)
	else 
		data 
	end 
end 

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
                Expr(:call, :repeat , Expr(:call, popfun , Expr(:$, :key)) ,:num), :num)
#     expr = Expr(:call, :pipelines, Expr(:$, :redis), 
#             Expr(:(...), Expr(:call, :rep , Expr(:call, popfun , Expr(:$, :key)) ,:num))) 

    body =  Expr(:block, 
                Expr(:(=), :data, Expr(:call, :Vector, :undef, 0)) ,
                Expr(:function, Expr(:call, :f), Expr(:block, 
                                Expr(:(&&), Expr(:call , :(>=) , Expr(:call, :length, :data) , 1), 
                                                                        Expr(:call, Expr(:$, :fun), :data) ))),
                Expr(:call, :atexit , :f) ,
                Expr(:(=), :freq, Expr(:call, :ftime)),
                Expr(:while , true, 
                    Expr(:block, Expr(:macrocall, Symbol("@cheak_reline"), "", Expr(:$, :redis)) , 
                    nums ,
                    Expr(:if , Expr(:call, :(>=), :num ,1), 
                                        Expr(:block, 
                                                    Expr(:(=), :data , expr ),
                                                    Expr(:call, Expr(:$, :fun), :data), 
                                                    Expr(:(=), :data, Expr(:call, :Vector, :undef, 0)),
                                                    Expr(:call, :finit, :freq )),
                                        Expr(:block, Expr(:if , Expr(:call, :(>=), Expr(:(.) , :freq, :(:t)), 600),
                                                                    Expr(:call, :sleep, 600), 
                                                                    Expr(:call, :sleep, Expr(:call, :fadd, :freq)) 
                                                                     ))))))

             esc( Expr( :macro , func,   Expr(:block, Expr(:call, :esc,Expr(:quote, body)))))   

end 

@genmacro spop scard spop
@genmacro lpop llen lpop
@genmacro rpop llen rpop

