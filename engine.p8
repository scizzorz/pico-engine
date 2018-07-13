pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-->8
-- object
-- https://github.com/eevee/klinklang/blob/23c5715bda87f3c787e1c5fe78f30443c7bf3f56/object.lua (modified)

_object = {}
_object.__index = _object

-- constructor
function _object:__call(...)
  local this = setmetatable({}, self)
  return this, this:init(...)
end

-- methods
function _object:init() end
function _object:update() end
function _object:draw() end

-- subclassing
function _object:extend()
  proto = {}

  -- copy meta values, since lua
  -- doesn't walk the prototype
  -- chain to find them
  for k, v in pairs(self) do
    if sub(k, 1, 2) == "__" then
      proto[k] = v
    end
  end

  proto.__index = proto
  proto.__super = self

  return setmetatable(proto, self)
end


-->8
-- event handler
-- https://www.lexaloffle.com/bbs/?pid=38910&tid=29075

function _events()
  local all = {}
  return {
    on = function(t, h)
      if (nil == all[t]) then
        all[t] = {}
      end
      add(all[t], h)
    end,
    off = function(t, h)
      del(all[t], h)
    end,
    emit = function(t, e)
      foreach(
        all[t],
        function(h)
          h(e)
        end
      )
    end
  }
end


-->8
-- state machine

function _machine()
  local stack = {}

  function fire_up(ev, data)
    foreach(stack, function(h) h[ev](h, data) end)
  end

  function fire_down(ev, data)
    for i=#stack, 1, -1 do
      if stack[i][ev](stack[i], data) then
        break
      end
    end
  end

  return {
    fire_up=fire_up,
    fire_down=fire_down,
    update = function() fire_down('update') end,
    draw = function() fire_up('draw') end,
    pop = function() stack[#stack] = nil end,
    push = function(k) add(stack, k) end,
  }
end

-->8
-- colors
c_black=0
c_darkblue=1
c_darkpurple=2
c_darkgreen=3
c_brown=4
c_darkgrey=5
c_lightgrey=6
c_white=7
c_red=8
c_orange=9
c_yellow=10
c_green=11
c_blue=12
c_indigo=13
c_pink=14
c_peach=15


-->8
-- buttons
b_left = 0
b_right = 1
b_up = 2
b_down = 3
b_o = 4
b_x = 5
b_pause = 6


-->8
-- demo
game = _machine()

x = 60
y = 60

world = _object:extend()

function world:init()
  self.x = 0
end

function world:update()
  if btn(b_left) then x -= 1 end
  if btn(b_right) then x += 1 end
  if btn(b_up) then y -= 1 end
  if btn(b_down) then y += 1 end

  if btnp(4) or btnp(5) then
    game:push(menu())
  end
end

function world:draw()
  rectfill(0, 0, 128, 128, c_darkgreen)
  rectfill(x, y, x + 8, y + 8, c_brown)
end

menu = _object:extend()

function menu:draw()
  rectfill(8, 8, 120, 120, c_lightgrey)
  rectfill(9, 9, 119, 119, c_darkblue)
end

function menu:update()
  if btnp(4) or btnp(5) then
    game:pop()
  end
  return true
end

game:push(world())

function _draw() game:draw() end
function _update() game:update() end
