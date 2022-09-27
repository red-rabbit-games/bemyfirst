require('test/mainreset')

function love.load(...) end

function love.draw()
    Tst7:drawHor(120)
end

function love.update(dt)
    Tst7:update(dt)
end

function love.keypressed(key) if key == 'escape' then love.event.push('quit') end end

function love.mousepressed(x, y, button, istouch, presses)
    if love.keyboard.isDown("lalt") then
        if button == 1 then Tst7:setMin(x) end
        if button == 2 then Tst7:setMax(x) end
    else
        if button == 1 then Tst7:setPush(x) end
        if button == 2 then Tst7:setValue(x) end
    end
    Tst7:updTimer()
end

function love.wheelmoved( x , y )
    Tst7:setDeltaPush( math.max(0, Tst7.delta + y * 32) )
    print(Tst7.delta)
end

function love.resize(w, h) end

-- -- -- -- -- [ test ] -- -- -- -- --

---@class obj.CamVals7
CamVals7 = {
    min = 0 ,
    max = 0 ,

    value = 0 ,
    push = 0 ,

    -- v = 0 , -- збережений коефіцієнт value
    p = 0 , -- збережений коефіцієнт push

    delta = 0 ,

    speed = 200 , -- px/sec
    timer = 0 , -- 0 означає, що хоча б раз об’єкт буде оновлено
    dflt = 0.2 ,

    -- dpos = 0,
}

-- об’єкт

-- 
function CamVals7:new(...)
    ---@type obj.CamVals7
    local obj = {}
    for key, value in pairs(self) do
        obj[key] = value
    end

    local input = {...}
    table.sort(input)

    if #input > 0 then
        obj:setMax( input[#input] )
    end
    if #input > 1 then
        obj:setMin( input[1] )
    end

    obj:setV(0)

    return obj:initSeed()
end
-- 
function CamVals7:initSeed( _speed )
    if _speed == self.speed or _speed == 0 then return self end

    self.speed = _speed and math.abs(_speed) or self.speed
    self.timer = nil
    self.update = self.updateSpeedo

    return self
end
-- 
function CamVals7:initTimer( _timer )
    if _timer == self.timer then return self end

    self.timer = 0
    self.dflt = _timer and math.abs(_timer) or self.dflt
    self.update = self.updateTimed

    return self
end
-- -- 
-- function CamVals7:initHor( y ) end
-- -- 
-- function CamVals7:initVer( x ) end


-- додаткові фічі до об’єкту

-- демо
function CamVals7:drawVert( x )
    if self.delta > 0 then
        love.graphics.setColor(0.75, 0.75, 0.75)
        love.graphics.rectangle("fill", x - 2, self.min, self.delta, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", x - 2, self.min, self.delta, 4)
    end
    love.graphics.setColor(0.5, 0.5, 1)
    love.graphics.circle("fill", x, self.value, 8, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", x, self.push, 8, 20)
end
-- демо
function CamVals7:drawHor( y )
    if self.delta > 0 then
        love.graphics.setColor(0.75, 0.75, 0.75)
        love.graphics.rectangle("fill", self.min, y - 2, self.delta, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", self.min, y - 2, self.delta, 4)
    end
    love.graphics.setColor(0.5, 0.5, 1)
    love.graphics.circle("fill", self.value, y, 8, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", self.push, y, 8, 20)
end

-- 
function CamVals7:update( dt ) end
-- оновлювати value за швидкістю
function CamVals7:updateSpeedo( dt )
    if self.value ~= self.push then
        local step = self.speed * dt
        local delta = self.push - self.value
        if step > math.abs(delta) then
            self:setValue( self.push )
        else
            self:addValue( 0 > delta and -step or step )
        end
    end
end
-- оновлювати value за часом
function CamVals7:updateTimed( dt )
    if self.timer > 0 then
        if self.value == self.push then
            self.timer = -1
            return
        end
        if dt >= self.timer then
            self:setValue( self.push )
            self.timer = -1
            print(self.timer)
        else
            self:addValue( (self.push - self.value) * (dt / self.timer) )
            self.timer = self.timer - dt
        end
    end
    if self.timer == 0 then
        self:setValue( self.push )
        self.timer = -1
    end
end

-- function CamVals7:getK( value ) end


-- [!]   решта знущань по об’єкту, як правило, оминають атрибут value   [!] --
-- [!]    у той час, як push завжди прив’язаний до свого коефіцієнту    [!] --


-- min

-- нове значення
function CamVals7:setMin( _min )
    if _min == self.min then return end

    if _min > self.max then
        self.min = self.max
        self.max = _min
    else
        self.min = _min
    end

    self.delta = self.max - self.min -- оновити
    self.push = self.delta * self.p + self.min -- оновити
    -- self:updV()
    -- self:updTimer()
end
-- нове значення зі здвигом
function CamVals7:movMin( _min )
    if _min == self.min then return end

    local add = _min - self.min

    self.min = self.min + add
    self.max = self.max + add
    self.push = self.push + add

    -- self:updV()
    -- self:updTimer()
end


-- max

-- нове значення
function CamVals7:setMax( _max )
    if _max == self.max then return end

    if self.min > _max then
        self.max = self.min
        self.min = _max
    else
        self.max = _max
    end

    self.delta = self.max - self.min -- оновити
    self.push = self.delta * self.p + self.min -- оновити
    -- self:updV()
    -- self:updTimer()
end
-- нове значення зі здвигом
function CamVals7:movMax( _max )
    if _max == self.max then return end

    local add = _max - self.max

    self.min = self.min + add
    self.max = self.max + add
    self.push = self.push + add

    -- self:updV()
    -- self:updTimer()
end


-- value

-- встановити значення
function CamVals7:setValue( _value )
    if _value == self.value then return end

    self.value = _value

    -- self:updV()
    -- self:updTimer()
end
-- додати значення
function CamVals7:addValue( _add )
    self:setValue(self.value + _add)
end


-- push

-- встановити значення
function CamVals7:setPush( _push )
    if _push == self.push then return end

    self.push = math.max(self.min, math.min(self.max, _push))

    if self.delta ~= 0 then self.p = (self.push - self.min) / self.delta end -- оновити
    -- self:updTimer()
end
-- додати значення
function CamVals7:addPush( _add )
    self:setPush(self.push + _add)
end


-- v

-- новий коефіцієнт для value та його нове значення за цим коефіцієнтом
function CamVals7:setV( _v )
    if _v == self.v then return end

    self.v = _v

    self.value = self.delta * _v + self.min
    -- self:updTimer()
end


-- p

-- новий коефіцієнт для push та його нове значення за цим коефіцієнтом
function CamVals7:setP( _p )
    if _p == self.p then return end

    self.p = math.max(0, math.min(1, _p))

    self.push = self.delta * _p + self.min
    -- self:updTimer()
end


-- delta

-- нова delta на основі min
function CamVals7:setDeltaMin( _delta )
    if _delta == self.delta then return end

    if 0 > _delta then
        self.delta = math.abs(_delta)
        self.max = self.min
        self.min = self.max - _delta
    else
        self.delta = _delta
        self.max = self.min + _delta
    end

    self.push = self.delta * self.p + self.min -- оновити
    -- self:updV()
    -- self:updTimer()
end
-- нова delta на основі max
function CamVals7:setDeltaMax( _delta )
    if _delta == self.delta then return end

    if 0 > _delta then
        self.delta = math.abs(_delta)
        self.min = self.max
        self.max = self.min + _delta
    else
        self.delta = _delta
        self.min = self.max - _delta
    end

    self.push = self.delta * self.p + self.min -- оновити
    -- self:updV()
    -- self:updTimer()
end
-- нова delta на основі push
function CamVals7:setDeltaPush( _delta )
    if _delta == self.delta then return end

    self.delta = math.abs(_delta)
    self.min = self.push - self.delta * self.p
    self.max = self.push + self.delta * (1 - self.p)

    -- self:updV()
    -- self:updTimer()
end

-- -- нова delta на основі value
-- function CamVals7:setDeltaValue( _delta )
--     if _delta == self.delta then return end

--     self:updV()

--     self.delta = _delta
--     self.min = self.value - self.delta * self.v
--     self.max = self.value + self.delta * (1 - self.v)

--     self.push = self.delta * self.p + self.min -- оновити
-- end


-- різне

-- середнє арифметичне пікових значень
function CamVals7:getAvrg()
    return (self.min + self.max) / 2
end
-- оновлення таймеру (якщо є)
function CamVals7:updTimer()
    if self.timer then
        self.timer = self.dflt
    end
end

-- -- оновити коефіцієнт value,
-- -- але покищо вона потрібна лише для setDeltaValue,
-- -- яка навряд чи буде використовуватися, тож...
-- function CamVals7:updV()
--     if self.delta ~= 0 then
--         self.v = (self.value - self.min) / self.delta
--     end
-- end


-- 

-- отримати значення
-- function CamVals7:getMin() return self.min end

-- отримати значення
-- function CamVals7:getMax() return self.max end

-- отримати значення
-- function CamVals7:getValue() return self.value end

-- отримати значення
-- function CamVals7:getPush() return self.push end

-- отримати значення
-- function CamVals7:getV( _v ) return self.v end

-- отримати значення
-- function CamVals7:getV( _p ) return self.p end

-- отримати значення
-- function CamVals7:getDelta() return self.delta end


-- -- -- -- -- [ test ] -- -- -- -- --

Tst7 = CamVals7:new(50, 450):initTimer(0.3)

-- -- -- -- -- [ test ] -- -- -- -- --
