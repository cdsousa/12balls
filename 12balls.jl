immutable TwelveBalls
    odd::Int
    weight::Float64
    function TwelveBalls(odd, weight)
        if !(1 <= odd <= 12)
            error("Odd ball number must be from 1 to 12")
        end
        if weight <= 0 || weight == 1
            error("Weight must be positive and different from 1")
        end
        new(odd, weight)
    end
end

function TwelveBalls()
    odd = rand(1:12)
    if rand(Bool)
        weight = 1.0-0.1*rand(1:9)
    else
        weight = 1.0+abs(randn())+0.0001
    end
    TwelveBalls(odd, weight)
end

function TwelveBalls(odd)
    TwelveBalls(odd, TwelveBalls().weight)
end


function balance12balls(tb::TwelveBalls, leftballs, rightballs)
    l,r = Set(leftballs), Set(rightballs)
    if minimum(l) < 1 || 12 < maximum(l) || minimum(r) < 1 || 12 < maximum(r)
        error("One or more balls have invalid numbers")
    end
    lw, rw = length(l), length(r)
    if lw != length(leftballs) || rw != length(rightballs) || !isempty(l ∩ r)
        error("One or more balls are repeated!")
    end
    if tb.odd in l
        lw += -1.0 + tb.weight
    elseif tb.odd in r
        rw += -1.0 + tb.weight
    end
    if lw>rw
        :left
    elseif lw<rw
        :right
    else
        :center
    end
end


type TwelveBallsBalance
    tb::TwelveBalls
    num::Int
    TwelveBallsBalance(tb::TwelveBalls) = new(tb, 3)
end

function Base.call(b::TwelveBallsBalance, l, r)
    if b.num <= 0
        error("You can't use this balance again")
    else
        b.num -= 1
        balance12balls(b.tb, l, r)
    end
end

function test_solver(solverfn, testset=1:12)
    passed = true
    for i in testset
        for w in (0.5, 1.5)
            tb = TwelveBalls(i,w)
            balance = TwelveBallsBalance(tb)
            balancefn = (l,r) -> balance(l,r)
            odd, weight = solverfn(balancefn)
            realweight = tb.weight > 1 ? :heavier : :lighter
            ok = odd==tb.odd && weight==realweight
            passed &= ok
            println(ok ? "OK    " : "FAIL  ", "  real: $(tb.odd) $realweight   solved: $odd $weight")
        end
    end
    return passed
end




begin
    function my_12balls_solver(balance)
        m1 = balance(1:4, 5:8)
        if m1 == :center
            m2 = balance(1:3, 9:11)
            if m2 == :center
                m3 = balance(1, 12)
                if m3 == :left
                    return 12, :lighter
                elseif m3 == :right
                    return 12, :heavier
                else
                    error()
                end
            elseif m2 == :left
                m3 = balance(9, 10)
                if m3 == :center
                    return 11, :lighter
                elseif m3 == :left
                    return 10, :lighter
                else
                    return 9, :lighter
                end
            else
                m3 = balance(9, 10)
                if m3 == :center
                    return 11, :heavier
                elseif m3 == :left
                    return 9, :heavier
                else
                    return 10, :heavier
                end
            end
        else
            if m1 == :left
                maybeheavy = 1:4
                maybelight = 5:8
            else
                maybeheavy = 5:8
                maybelight = 1:4
            end
            m2 = balance([maybeheavy[1:3]; maybelight[4]], [9:11; maybeheavy[4]])
            if m2 == :center
                m3 = balance(maybelight[1], maybelight[2])
                if m3 == :center
                    return maybelight[3], :lighter
                elseif m3 == :left
                    return maybelight[2], :lighter
                else
                    return maybelight[1], :lighter
                end
            elseif m2 == :left
                m3 = balance(maybeheavy[1], maybeheavy[2])
                if m3 == :center
                    return maybeheavy[3], :heavier
                elseif m3 == :left
                    return maybeheavy[1], :heavier
                else
                    return maybeheavy[2], :heavier
                end
            else
                m3 = balance(maybeheavy[4], 9)
                if m3 == :center
                    return maybelight[4], :lighter
                elseif m3 == :left
                    return maybeheavy[4], :heavier
                else
                    error()
                end
            end
        end
    end

    test_solver(my_12balls_solver, 1:12)
end
