output = File.new("output.txt","w")
input = File.new("taillard/tai75a.dat","r") 
line = input.gets.split
num = line[0].to_i
best = line[1].to_f
$load = input.gets.to_i
$MAX = 1000000000000
class Cust
	attr_accessor :x, :y, :load,:angle,:index
	def initialize(index,x,y,load)
		@index = Integer(index)
		@x = Float(x)
		@y = Float(y)
		@load = Integer(load)
		@angle = Float(0)
	end
	def <=>(other)
		self.angle <=> other.angle
	end
	def count_dist(other)
		Math.sqrt((@x - other.x) ** 2 + (@y - other.y) ** 2)
	end
	def count_angle(origin)
		@angle = 	if @x - origin.x > 0 && @y - origin.y >= 0
						Math.atan( (@y - origin.y) / (@x -  origin.x) )
					elsif @x - origin.x < 0
						Math.atan( (@y - origin.y) / (@x -  origin.x) ) + Math::PI
					elsif @x - origin.x > 0 && @y - origin.y < 0
						Math.atan( (@y - origin.y) / (@x -  origin.x) ) + Math::PI * 2
					elsif @x - origin.x == 0.0 && @y - origin.y > 0
						Math::PI / 2.0
					elsif @x - origin.x == 0.0 && @y - origin.y < 0
						Math::PI  * 3 / 2.0
					else
						0.0
					end
	end
end
class Gene
	attr_accessor :splits, :gene, :cost
	def initialize(route)
		@splits = []
		@gene = Array.new(route)
		@cost = 0	
	end

end
origin = Cust.new(0,0,0,$load)
line = input.gets.split
origin.x = line[0].to_f
origin.y = line[1].to_f
cust = Array.new
input.each do	|line|
	temp = line.split
	cust << Cust.new(temp[0],temp[1],temp[2],temp[3])
end

$dist = []
(num+1).times { $dist << Array.new(num+1,0)}

for i in (0..num-1)
	for j in (i..num-1)
		$dist[cust[j].index][cust[i].index] = $dist[cust[i].index][cust[j].index] = cust[i].count_dist(cust[j])
	end
end
cust.each do |indi| 
	indi.count_angle(origin) 
	$dist[indi.index][0] = $dist[0][indi.index] = origin.count_dist(indi)
end

cust.sort!
route = []
cust.each_with_index { |c,index| route << index  }
population = Array.new
cust.length.times do
	population << Gene.new(route)
	route.push(route.shift)
end
population.each do |individual|
	vload = 0
	individual.gene.each_with_index do	|node,index|
		if vload + cust[node].load <= $load
			vload += cust[node].load
		else
			individual.splits << index
			vload = cust[node].load
		end
	end
end

def find_min_path (cust,othercust)
	min = $MAX
	index = 0
	othercust.each do |pcust|
		if $dist[cust][pcust] < min
			min = $dist[cust][pcust]
			index = pcust
		end
	end
	return min,index
end
population.each do |individual|
	pathCost = 0
	temppath = []
	vpath = []
	individual.gene.each_with_index do |node,index|
		temppath << node
		if individual.splits.include?(index)
			cur = 0
			while !temppath.empty?
				edge,cur = find_min_path(0,temppath)
				pathCost += edge
				vpath << cur
				temppath.delete cur
			end
			pathCost += $dist[0][vpath[-1]]
		end
	end
	individual.gene = Array.new(vpath)
	individual.cost = pathCost
end

p population




