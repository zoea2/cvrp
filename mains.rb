output = File.new("output.txt","w")
input = File.new("taillard/tai75a.dat","r") 
line = input.gets.split
num = line[0].to_i
best = line[1].to_f
class Cust
	attr_accessor :x, :y, :load,:angle,:index
	def initialize(index,x,y,load)
		@index = Integer(index)
		@x = Integer(x)
		@y = Integer(y)
		@load = Integer(load)
		@angle = Float(0)
	end
	def <=>(other)
		self.angle <=> other.angle
	end
	def countdist(other)
		Math.sqrt((self.x - other.x) ** 2 + (self.y - other.y) ** 2)
	end
	def countangle(origin)
		@angle = 	if @x - origin.x > 0 && @y - origin.y > 0
						Math.atan( (@y - origin.y) / (@x -  origin.x) )
					elsif @x - origin.x < 0
						Math.atan( (@y - origin.y) / (@x -  origin.x) ) + Math::PI
					elsif @x - origin.x > 0 && @y - origin.y < 0
						Math.atan( (@y - origin.y) / (@x -  origin.x) ) + Math::PI * 2
					else
						0.0
					end
	end
end
origin = Cust.new(0,0,0,0)
origin.load = input.gets.to_i
line = input.gets.split
origin.x = line[0].to_i 
origin.y = line[1].to_i
cust = Array.new
input.each do	|line|
	temp = line.split
	cust << Cust.new(temp[0],temp[1],temp[2],temp[3])
end
cust.each { |indi| indi.countangle(origin) }
cust.sort!
p cust
