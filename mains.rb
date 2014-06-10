require "opengl"
require 'glu'
require 'glut'
include Gl,Glu,Glut
output = File.new("output.txt","w")
input = File.new("taillard/tai75a.dat","r") 
line = input.gets.split
num = line[0].to_i
best = line[1].to_f
$load = input.gets.to_i
$MAX = 1000000000000
$pCross = 0.3
$pMutation = 0.01
$dist = []
$scale = 100.0
$generation = 0
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
	attr_accessor :splits, :gene, :cost, :leftFit,:rightFit
	def initialize(route=[])
		@splits = []
		@gene = Array.new(route)
		@cost = 0
		@leftFit = 0
		@rightFit = 0
	end
	def dclone
		temp = Gene.new(@gene)
		temp.splits = Array.new(@splits)
		temp.cost = @cost
		temp.leftFit = @leftFit
		temp.rightFit = @rightFit
		temp
	end
	def split_route
		vload = 0
		@splits = []
		@gene.each_with_index do	|node,index|
			if vload + $cust[node].load <= $load
				vload += $cust[node].load
			else
				@splits << index - 1
				vload = $cust[node].load
			end
		end
	end
	def count_cost(num)
		pcost = @cost
		cur = 0
		@cost = 0
		@gene.each_with_index do |node,index|
			@cost += $dist[cur][$cust[node].index]
			if @splits.include?(index) || index == num - 1 
				@cost += $dist[$cust[node].index][0]
				cur = 0
			else
				cur = $cust[node].index
			end
		end
	end
	def to_s
		path = []
		path2 = []
		allpath = []
		loads = []
		@gene.each_with_index do |node,index|
			path << $cust[node].index
			path2 << node
			if @splits.include? (index) || index == @gene.length - 1
				allpath << path
				load = 0
				path2.each { |i| load += $cust[i].load }
				loads << load
				path = []
				path2 = []
			end
		end
		"path = #{allpath} \nloads = #{loads}\ncost = #{ @cost} \n"
	end


end
draw_line2 = proc do
	glClear (GL_COLOR_BUFFER_BIT)
	glColor3f(1.0,1.0,1.0)
	glBegin(GL_LINES)
	glVertex2f(30/$scale,30/$scale)
	glVertex2f(40/$scale,10/$scale)
	glVertex2f(40/$scale,10/$scale)
	glVertex2f(-36/$scale,25/$scale)
	glEnd()	
	glFlush()
end
draw_line = proc do 
	glClear (GL_COLOR_BUFFER_BIT)
	glColor3f(1.0,1.0,1.0)
	glBegin(GL_LINES)
	path2 = [$best.gene.length]
	$best.gene.each_with_index do |node,index|
		path2 << node
		if $best.splits.include?(index) || index == $best.gene.length - 1
			path2 << $best.gene.length
			path2.each_with_index do |point,index0|				
				if index0 < path2.length - 1 
					#glBegin(GL_LINES)
					cur = point
					if cur == $best.gene.length
						glVertex2f($origin.x/$scale,$origin.y/$scale)
					else
						glVertex2f($cust[cur].x/$scale,$cust[cur].y/$scale)
					end
					cur = path2[index0+1]
					if cur == $best.gene.length
						glVertex2f($origin.x/$scale,$origin.y/$scale)
					else
						glVertex2f($cust[cur].x/$scale,$cust[cur].y/$scale)
					end
				end				
			end
			path2 = [$best.gene.length]
		end

	end
	glEnd()	
	glFlush()
	glutSwapBuffers()
end

$origin = Cust.new(0,0,0,$load)
line = input.gets.split
$origin.x = line[0].to_f
$origin.y = line[1].to_f
$cust = Array.new
num.times do
	line = input.gets
	temp = line.split
	$cust << Cust.new(temp[0],temp[1],temp[2],temp[3])
end


(num+1).times { $dist << Array.new(num+1,0)}

for i in (0..num-1)
	for j in (i..num-1)
		$dist[$cust[j].index][$cust[i].index] = $dist[$cust[i].index][$cust[j].index] = $cust[i].count_dist($cust[j])
	end
end
$cust.each do |indi| 
	indi.count_angle($origin) 
	$dist[indi.index][0] = $dist[0][indi.index] = $origin.count_dist(indi)
end

$cust.sort!
route = []
$cust.each_with_index { |c,index| route << index  }
population = Array.new
$cust.length.times do
	population << Gene.new(route)
	route.push(route.shift)
end
population.each { |indi| indi.split_route }

def find_min_path (origin,othercust)
	min = $MAX
	index = 0
	cur = 0
	othercust.each do |pcust|
		#uts cur
		if $dist[origin][$cust[pcust].index] < min
			min = $dist[origin][$cust[pcust].index]
			cur = $cust[pcust].index
			index = pcust
		end
	end
	return min,cur,index
end
#p population[0]
def recombine(population,num)
	population.each_with_index do |individual,index0|
		pathCost = 0
		temppath = []
		vpath = []
		individual.gene.each_with_index do |node,index|
			temppath << node
			if individual.splits.include?(index) || index == num  - 1
				cur = 0
				while !temppath.empty?
					edge,cur,indexs = find_min_path(cur,temppath)
					pathCost += edge				
					vpath << indexs		
					temppath.delete indexs
				end
				pathCost += $dist[0][$cust[vpath[-1]].index]
			end
		
		end
		individual.gene = Array.new(vpath)
		individual.cost = pathCost
	end
end
recombine(population,num)
#p population[0]
$best = Gene.new
$best.cost = $MAX
def keep_best_gene(best,population)
	population.each do |indi|
		if indi.cost < best.cost
			best = indi.dclone
		end
	end
	best
end
$best = keep_best_gene($best,population)
p $best
$best.count_cost(num)
p $best
newPopulation = Array.new
#population.each { |indi|  newPopulation << indi.dclone }
def rand_val(left = 0,right = 1)
	rand(10000000) / 10000000.0 * (right - left) + left
end
def Roulette(population,newPopulation,num)
	left = 0
	population.each do |indi|
		indi.leftFit = left
		left += 4000 - indi.cost
		indi.rightFit = left
	end
	newPopulation.clear
	num.times do |i|
		r = rand_val(0,left)
		population.each do |indi|
			if indi.leftFit <= r && indi.rightFit > r
				newPopulation << indi.dclone
				break
			end
		end
	end
end
def cross(newPopulation,num)
	newPopulation.each_with_index do |indi,index|
		if rand_val < $pCross
			r0 = rand(num)
			r0 = rand(num) while r0 == index
			r1 = rand(num)
			r2 = rand(num)
			r2 = rand(num) while r2 == r1
			if r2 < r1
				temp = r1
				r1 = r2
				r2 = temp
			end
			temp = newPopulation[r0].gene.values_at(r1..r2)
			temp.each do |i|
				newPopulation[index].gene.delete i
			end
			temp.reverse!
			temp.each { |i| newPopulation[index].gene.insert(r1,i) }
		end
	end
end
def mutation(newPopulation,num)
	newPopulation.each_with_index do |indi,index|
		indi.gene.each_with_index do |pgene,index0|
			if rand_val < $pMutation
				r1 = rand(num)
				r1 = rand(num) while r1 == index0
				temp = newPopulation[index].gene[index0]
				newPopulation[index].gene[index0] = newPopulation[index].gene[r1]
				newPopulation[index].gene[r1] = temp
			end
		end
	end

end
def throw_worst(best,population)
	max = 0
	index0 = 0
	population.each_with_index do |idvi,index|
		if max < idvi.cost
			max = idvi.cost
			index0 = index
		end
	end
	population[index0] = best.dclone
end
myIdle = proc do
	$generation += 1
	Roulette(population,newPopulation,num)
	cross(newPopulation,num)
	mutation(newPopulation,num)
	newPopulation.each do |idvi|
		idvi.split_route()
		idvi.count_cost(num)
	end
	$best = keep_best_gene($best,newPopulation) 
	throw_worst($best,newPopulation)
	population.clear
	newPopulation.each {|idvi| population << idvi.dclone}	
	if $generation % 100 == 0		
		puts $generation	
		puts $best
	end
	draw_line.call
end
output = File.new("output.txt","w")
output.puts best 

glutInit
glutInitDisplayMode (GLUT_RGBA | GLUT_DOUBLE)
glutInitWindowSize(1000,500)
glutInitWindowPosition(100, 100)
glutCreateWindow
glutDisplayFunc(draw_line)
glutIdleFunc(myIdle)
glutMainLoop()


output.puts population
output.puts best 
output.close


