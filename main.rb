output = File.new("output.txt","w")
input = File.new("taillard/tai75a.dat","r")
line = input.gets.split
num = line[0].to_i
best = line[1].to_f
$load = input.gets.to_i
class Cust
	attr_accessor :x,:y,:load,:index
	def initialize(index,x,y)
		@index = index
		@x = x
		@y = y
		@load = $load
	end

	def <=>(other)
	end

	def contdist(other)
		Math.sqrt((self.x - other.x) ** 2 + (self.y - other.y) ** 2)
	end

end

origin = Cust.new(0,0,0)
line = input.gets.split
origin.x = line[0].to_i
origin.y = line[1].to_i

p origin



input.close
output.close
