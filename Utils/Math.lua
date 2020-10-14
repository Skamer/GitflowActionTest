-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling "SylingTracker.MathUtils" ""

namespace                          "SLT"

pow = math.pow

-- method
-- Linear
-- QuadraticEaseIn
-- QuadracticEaseOut
-- QuadracticEaseInout 
-- ExponentialEaseIn
-- ExponentialEaseOut
-- ExponentialEaseInOut
--

class "Utils" (function(_ENV)

  class "Math" (function(_ENV)

    __Static__() function Linear(t, b, c, d)
      return c * t / d + b
    end

    __Static__() function QuadraticEaseIn(t, b, c, d)
      t = t / duration
      return c * pow(t, 2) + b
    end
    
    __Static__() function QuadraticEaseOut(t, b, c, d)
      t = t / d
      return -c * t * (t - 2) + b
    end
    
    __Static__() function QuadraticEaseInOut(t, b, c, d)
      t = t / d * 2
      if t < 1 then
        return c / 2 * pow(t, 2) + b
      else
        return -c / 2 * ((t - 1) * (t - 3) - 1) + b
      end
    end

    __Static__() function ExponentialEaseIn(t, b, c, d)
      if t == 0 then
        return b
      else
        return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
      end
    end
    
    __Static__() function ExponentialEaseOut(t, b, c, d)
      if t == d then
        return b + c
      else
        return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
      end
    end
    
    __Static__() function ExponentialEaseInOut(t, b, c, d)
      if t == 0 then return b end
      if t == d then return b + c end
      t = t / d * 2
      if t < 1 then
        return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005
      else
        t = t - 1
        return c / 2 * 1.0005 * (-pow(2, -10 * t) + 2) + b
      end  
    end

  
    __Arguments__ { Number, Variable.Optional(Number, 0) }
    __Static__() function TruncateDecimal(number, decimal)
      local tenPower = math.pow(10, decimal)

      return math.floor(number * tenPower)/ tenPower
    end
    
  end)
end)
