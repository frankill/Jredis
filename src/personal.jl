const TIMES = 2
const TNUM = 0
const sym = ['\$', '+', '-', ':' , '*']
mutable struct Ftime
    t::Int
    num::Int
end

ftime() = Ftime(TIMES, TNUM)
@inline function fadd(t::Ftime)
	 		if t.t >= 600
				t.num += 1
			else
				t.t += TIMES
			end
		end
@inline finit(t::Ftime) = t.t > 2 && begin t.t, t.num = TIMES, TNUM end 

@inline redis_test(conn::RedisConnection,test::AbstractString) = send_command(conn, echo(test) )

function redis_collect(conn::RedisConnection , test::AbstractString="test")

	res = redis_test(conn, test)
	collects(conn,test , [])

end

function collects(conn::RedisConnection , test::AbstractString, data::Vector)
	tmp = readline(conn.socket)
	syms, value = tmp[1] , tmp[2:end]
	if (syms in sym)
		val = reply(redisreply{Symbol(syms)}, value, conn.socket)
		if val != test
			push!(data, val )
		else
			return data
		end
	else
		push!(data, tmp)
	end
	collects(conn, test, data)
end

function reline(conn::RedisConnectionBase, times::Ftime, fun::Function)
    println("Failed to connect to Redis server ,Reconnect after $(times.t) seconds .")
    sleep(times.t)
    try
        reconnect(conn)
        println("""
			Success to connect to Redis server ,
			Time consuming greater than or equal to $(fun(times)) seconds .
			""")
    catch
        fadd(times)
        reline(conn, times, fun)
    end

end

macro cheak_reline(conn )

	function f(x::Ftime)::Int
		if x.num >0
			x.num * 600
		else
			(x.t/4)*x.t + (x.t/2 )
		end
	end

    con = esc(conn)
    quote
        try
            ping( $con )
        catch
            reline( $con , ftime(), $f)
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

	body =  Expr(:block,
		    Expr(:(=), :freq, Expr(:call, :ftime)),
		    Expr(:while , true,
			Expr(:block, Expr(:macrocall, Symbol("@cheak_reline"), "", Expr(:$, :redis)) ,
			nums ,
			Expr(:if , Expr(:call, :(>=), :num ,1),
					    Expr(:try, Expr(:block,
						    Expr(:global, Expr(:(=), :data , expr )),
						    Expr(:call, Expr(:$, :fun), :data),
						    Expr(:(=), :data, 0 ),
						    Expr(:call, :finit, :freq )),
						   false ,
						Expr(:block,
						    Expr(:(&&), Expr( :call, :!, Expr(:call , :(isa) , :data , :Int)), 
						    Expr(:call, Expr(:$, :fun), :data) ),
							Expr(:(=) , :tmp , Expr(:call, :redis_collect , Expr(:$, :redis))),
							Expr(:(&&), Expr(:call , :(>=) , Expr(:call, :length, :tmp) , 1),
							Expr(:call, Expr(:$, :fun), :tmp) ),
							Expr(:call, :disconnect, Expr(:$, :redis)))),
					    Expr(:block, Expr(:call, :sleep, Expr(:call, :fadd, :freq)))))))

		 esc( Expr( :macro , func,   Expr(:block, Expr(:call, :esc,Expr(:quote, body)))))

end

@genmacro spop scard spop
@genmacro lpop llen lpop
@genmacro rpop llen rpop
