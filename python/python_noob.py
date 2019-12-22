#字符串的基本用法：
#
#
file = open('/user/yourname/desktop/file.txt','w') #open内置函数 打开一个文件
file.write('hello,world!')  #file的方法write 把后面的字符串写入前面打开的文件

what_he_dose = 'plays'
his_instrument = 'guitar'
his_name = 'Robert Johnson'
artist_intro = his_name + what_he_dose + his_name  #字符串拼接
print(artist_intro)
print(type(artist_intro)) #打印变量类型

word = 'a looooooooog word'
num = 12
string = 'bang!'
total = string * (len(word) - num)
print(total)

#字符串的分片与索引
#
#
name = 'my name is mike'
print(name[10])  #打印位置10的分片 分片是从0开始计数的。
print(name[-4])  #打印倒数第四个分片
print(name[11:14]) #打印位置11到14 但不包括14的分片。
print(name[0:-1]) #打印从位置0开始到最后一个分片 但不包括-1这个分片
print(name[-4:])
print(name[:3]) #打印从位置0开始到位置3 但不包括位置3的分片

name='0123456789987654321'


word = 'friend'
find_the_evil_in_your_friends = word[0] + word[2:4] + word[-3:-1]
print(find_the_evil_in_your_friends) #打印新的变量

#字符串的方法：
#
#
phone_number = '1386-223-0222'
hiding_number = phone_number.replace(phone_number[:9],'*'*9) #[:9]从0开始到9 但不包含9
print(hiding_number)

#电话号码联想功能：使用字符串的find方法。
168

1386-186-0006
1681-222-0666

search = '168'
num_a = '1382-168-0006'
num_b = '1681-222-0006'
print(search + ' is at ' + str(num_a.find(search)+1) + ' to ' + str(num_a.find(search) + len(search)) + 'of num_a')
print(search + ' is at ' + str(num_b.find(search)+1) + ' to ' + str(num_b.find(search) + len(search)) + 'of num_b')

#字符串格式化符 利用方法填空
print('{} a word she can get what she {} for.'.format('With','came'))
print('{prepositon} a world she can get what she {verb} for.'.format(prepositon = 'With',verb= 'came'))
print('{0} a word she can get what she {1} for.'.format('With','came'))

#字符串填空：
city = input("write down the name of city:") #把输入的值赋给city这个变量
url = "http://apistore.baidu.com/weather/?citypinyin={}".format(city) #format把前面city的变量填入{}


##############重新认识函数
#
#
#built-in functions有68个
print()
input()
len()

#开始创建函数
#
#
#基本语法
def function(arg1,arg2):#定义函数以及传入的参数。
	return 'something'  #会返回一个值，但是这个值不会返回到前台。

--------
#摄氏度转化公式：
def fahrenheit_convert(C):
	fahrenheit = C * 9/5 +32
	return str(fahrenheit) + '°F'
#调用函数 call function
C2F = fahrenheit_convert(35) #调用函数 函数返回的值会赋给C2F这个变量
print(C2F)	#打印变量的值

---------
#TEST print is different from return.
#摄氏度转化公式：
def fahrenheit_convert(C):#定义函数
	fahrenheit = C * 9/5 +32
	print(str(fahrenheit) + '°F')#函数不会返回值，但是直接调用会打印。

#调用函数 call function
C2F = fahrenheit_convert(35)#会显示值，因为函数中有打印步骤
print(C2F)#不会打印任何值，因为函数没有返回任何值。

#result:
95.0°F
None

-----------------------------------------------------------
#练习题
#test1 重量转换器
#heavyconvert
def kgConvert(g):
    kgConvert = g / 1000
    return str(kgConvert) + 'kg'

arg1 = kgConvert(100000)
print (arg1)

def kgConvert(g):
	kgConvert = g / 1000
	return str(kgConvert) + 'kg'
arg2 = kgConvert(10000)
print(arg2)

#test2 求直角三角形斜边长的函数（两条直角边为参数，求最长边）
def countTriangleLength(c1,c2):
    #theThirdSideLength =
    return 'the right triangle third slide\'s length is {}'.format((c1**2 + c2**2 )**(1/2)) #**(1/2) 等价开根号

print (countTriangleLength(3,4))



#传递参数与参数类型
#ways：位置参数 positional argument 关键词参数 keyword argument
#example1 use positional argument
def trapezoid_area(base_up,base_down,height):
	return 1/2*(base_up + base_down)*height

print(trapezoid_area(1,2,3)) #1,2,3 corresponding to the parameters base_up, base_down and height respectively

#example2 use keyword argument
def trapezoid_area(base_up,base_down,height):
	return 1/2 * (base_up + base_down) * height

print(trapezoid_area(base_down=1,height=2,base_up=3))


#设计自己的函数
def text_create(name,msg):
	destop_path = '/Users/Hou/Desktop/'
	full_path = desktop_path + name + '.txt'
	file = oepn(full_path,'w')
	file.write(msg)
	file.close()
	print('Done')
text_create('hello','hello world')


#调用字符串的方法 替换功能 替换单词
def text_filter(word,censored_word = 'lame',changed_word = 'Awesome'):
	return word.replace(censored_word,changed_word)
print(text_filter('Python is lame!'))



#####逻辑控制与循环
#
#
#逻辑判断 True&False
#但凡能够产生一个布尔值的表达式 则可以称为布尔表达式


#比较运算
#比较运算符 == != < > <= >=
#
#
#多条件的比较。先给变量赋值。
middle = 5
1 < middle <10
#变量的比较。将两个运算结果储存在不同的变量中，然后再进行比较。
a = 1+20
b = 1+200
a < bang
#字符串的比较：python中有严格的大小写区分 不同类型的对象不能使用'< > >= <=’比较，可以使用== !=比较。

#成员运算符与身份运算符 Membership&Identify Operators
#集合类型：列表(list) 字符串、浮点、整数、布尔类型甚至是另一个列表都可以存储在列表中。

#创建一个列表
album = []
album =['Black star','David Bowie',25,True]
album.append('new song')#利用列表的方法 添加新的元素。新的元素会自动排列到列表的尾部
print(album[0],album[-1])#打印列表中第一个和最后一个元素
#运行结果：
====================== RESTART: E:/Scripts/temp_test.py ======================
Black star new song

#使用in来测试字符串是否存在列表中 in后面是一个集合形态的对象，字符串满足这种集合的特性，所以可以使用in测试。
album =['Black star','David Bowie',25,True]
print('Black star'  in album)#括号中返回的是布尔值
====================== RESTART: E:/Scripts/temp_test.py ======================
True

#条件控制
def account_login():  #定义函数
	password = input('password:') #获取用户输入的字符串并储存再变量password中；
	if password == '12345':#如果用户输入的字符串和预设的密码12345相等时，就执行打印文本
		print('Login success!')
	else: #反之则打印错误密码重新输入。
	    print('wrong password or invalid input!')
	    account_login()#运行函数
account_login()#调用函数


#给变量赋值
def account_login():
	password = input('Password:')
	password_correct = password == '12345'
	if password_correct:
		print('Login success!')
	else:
		print('Wrong password or invalid input!')
		account_login()
account_login()


#elif_demo

password_list = ['*#*','12345']  #创建一个列表，用于储存用户的密码 初始密码和其他数据（对实际数据库的简单模拟）
def account_login():             #定义函数
	password = input('Password:') #使用input获得用户输入的字符串并储存在变量password中
	password_correct = password == password_list[-1] #当用户输入的密码等于密码列表中最后一个元素的时候（即用户最新设定的密码），登陆成功
	password_reset = password == password_list[0] #用户输入的密码等于密码列表中的第一个元素（即‘重置密码’的口令）触发密码变更，并将比变更后的密码储存至 列表的最后一个。
	if password_correct:
		print('Login success!')
	elif password_rest:
		new_password = input('Enter a new password:')
		password_list.append(new_password)  #新重置的密码添加到列表当中
		print('Your password has changed successfully!')
		account_login()
	else:
		print('Wrong password or invalid input!')
		account_login()
account_login()


#循环loop
for every_letter in 'hello,world':
	print(every_letter)

for num in range(1,11):
	print(str(num) + ' + 1 =',num + 1)


#for&if 
songlist = ['Holy Diver','Thunderstruck','Rebel Rebel']
for song in songlist:
	if song == 'Holy Diver':
		print(song,' - Dio')
	elif song == 'Thunderstruck':
		print(song,'- AC/DC')
	elif song == 'Rebel Reble':
		print(song,' -David Bowie')

#Nestloop
for i in range(1,10):
	for j in range(1,10):
		print('{} X {} = {}'.format(i,j,i*j))

#While-loop
while 1 < 3:
	print('1 is smaller than 3')#如果不人为干预，会一直循环下去，俗称死循环。

#while-break
count = 0 #count的变量赋值为0
while True:
	print('repeat this line!')
	count = count + 1 #count重新赋值
	if count == 5:
		break


##whileLoginPassword
password_list = ['*#*#','12345']
def account_login():
	tries = 3
	while tries > 0 :
		password = input('Password:')
		password_corret = password == pasword_list[-1]
		password_reset = password == password_list[0]

		if password_corret:
			print('Login success')
		elif password_reset:
			new_password = input('Enter a new password:')
			password_list.append(new_password)
			print('Password has changed successfully')
			account_login()
		else:
			print('Wrong password or invalid input!')
			tres = tries - 1
			print(tries,'time left')

	else:
		print('Your account has been suspended')
		
account_login()


#在桌面文件夹创建10个文本，以数字给他们命名。
def text_creation():
	path = '/usr/hou/desktop'
	for name in range (1,11):
		with open(path + str(name) + '.txt' w) as text:
			text.write(str(name))
			text.close()
			print('Done')
text_creation

#复利公式
def invest(amount,rate,time):
	print("principal amount:{}".format(amount))
	for t in range(1,time+1):
		amount = amount * (1 + rate)
		print("year{}: ${}".format(t,amount))

invest(100,.05,8)
invest(2000,.025,5)

### 3 1-100 所有偶数
def even_print():
	for i in range(1,101):
		if i % 2 == 0:
			print(i)
even_print()

# comprehensive exercises
import random
def roll_dice(numbers=3, pints=None):  #创建函数，设定两个默认参数作为可选，numbers--骰子数量，points————三个筛子的点数的列表
	print('<<<<<ROLL THE DICE!>>>>>')  #告知用户开始摇骰子；
	if points is None:				   #如果参数中并未指定points，那么为points创建空的列表
		points = []					   
	while numbers > 0: 					#6-9 摇骰子三次，每次number减一，直到小于等于0时，循环停止；
		point = random.randrange(1,7)
		points.append(point)
		numbers = numbers - 1
	return points #返回结果的列表



def roll_result(total): #创建函数，其中必要的参数是骰子的总点数：
	isBig = 11 <= total <=18 #设定大与小的判断标准
	isSmall = 3 <= total <= 10
	if isBig:
		return 'Big'
	elif isSmall:
		return 'Small'  #在不同的条件下，返回不同的结果


def start_game(): #创建函数
	print('<<<<<GAME START!>>>>>')  #告知用户游戏开始
	choices = ['Big','Small']       #规定什么是正确的输入
	your_choices = input('Big or Small:') #将用户的输入字符串存储到your_choice中
	if your_choice in choices: #如果输入参数符合规范则往下进行，不符合则告知用户并重新开始
		points = roll_dice() #调用roll_dice函数,将返回的列表名为points；
		total = sum(points)  #点数求和
		youWin = your_choice == roll_result(total) #设定胜利的条件---你所选择的结果和计算机生成的结果是一致的；
		if youWin:
			print('The points are',points,'You win !')#9-16 成立则告知胜利，反之，则告知失败
		else:
			print('The points are',points,'You lose !')
	else:
		print('Invalid Words')
		start_game()
start_game()#调用函数，使程序运行。


# Data Structure
#列表、字典、元组、集合。
list = [val1,val2,val3,val4]
dict = {key1:val1,key2:val2}
tuple = (val1,val2,val3,val4)
set = {val1,val2,val3,val4}

#LIST
#1.列表中的每一个元素都是可变的；
#2.列表中的元素都是有序的，也就是说每一个元素都有一个位置；
#3.列表可以容纳python中的任何对象。
Weekday = ['Monday','Tuesday','Wednesday','Thursday','Friday']
print(Weekday[0])

#列表可以装入python中所有的对象
all_in_list = [
	1,	#整数
	1.0，#浮点数
	'a word',  #字符串
	print(1), #函数
	True,     #布尔值
	[1,2], #列表中套列表
	(1,2), #元组 
	{'key':'value'} #字典
]

#列表的增删改查

fruit = ['pineapple','pear']
fruit.insert(-1,'banana')  #使用insert插入的位置就是插入新的元素的位置，插入元素的实际位置是在“指定位置元素之前的位置“
fruit.insert(3,'grape') #超出实际位置，会被放在列表的最后位置
fruit.insert(0,'orange')
print(fruit)

fruit = ['pineapple','pear']
fruit[0:0] = ['orange'] #插入到0位置
print(fruit)

#删除列表中的元素
fruit = ['pipeapple','pear']
fruit.remove('pear')
print(fruit)

#删除的另外一种方法
del fruit[0:2]
print(fruit)


#替换列表中的元素
fruit = ['pipeapple','pear']
fruit[0] = 'Grapefruit'
print(fruit)

#列表的索引与字符串的切片相似。
periodic_table = ['H','He','Li','Be','B','C','N','O','F','Ne']
print(periodic_table[0])
print(periodic_table[-2])
print(periodic_table[0:3])#从位置0到位置2，最右边的值不取
print(periodic_table[-10:-7])
print(periodic_table[-10:])
print(periodic_table[:9])

#Dictionary
#键值对
#1.字典中数据必须是以键值对的形式出现的
#2.逻辑上讲，键是不能重复的，而值是可以重复的。
#3.字典中的键是不可变的，也就是无法修改的，而值(value)是可变的，可修改的，可以是任何对象。

#字典的书写方式
NASDAQ_code = {
	'BIDU':'Baidu',
	'SINA':'Sina',
	'YOKU':'Youku'
}
#如果键值对只有键没有值，会造成语法错误。只有值没有键也会造成语法错误。
#key和value是一一对应的，key是不变的。
#字典中的值不会有重复，即便有重复，也只会出现一次。
a = {
	'key':123,
	'key':123
}
print(a)

#字典的增删改查
NASDAQ_code = {
	'BIDU':'Baidu',
	'SINA':'Sina'
}
 #Insert
 NASDAQ_code['YOKU'] = 'Yoku'
 print(NASDAQ_code)

 #Insert多个元素
 NASDAQ_code.update({'FB':'Facebook','TSLA':'Tesla'})
 print(NASDAQ_code)

 #delete字典中的元素
 del NASDAQ_code['FB']

 #字典是通过键来索引值
 print NASDAQ_code['TSLA']

 #字典是不能够切片的

 
 #Tuple 元组
 #稳固版的列表，因为元组是不能修改的，因此列表中的存在的方法均不可使用在元组上，但是元组是可以被查看索引的，方式和列表一样：
 letters = ('a','b','c','d','e','f','g')
 letter[0]

 #Set 集合
 #集合更接近数学上的集合，每一个集合里的元素都是无序的、不重复的任意对象，我们可以通过集合取判断数据的从属关系，有时还可以通过集合把数据结构中重复的元素减掉。
 #集合不能被切片也不能被索引，除了做集合预算之外，结合元素可以被添加还有删除：
 a_set = {1,2,3,4,5}
 a_set.add(6)
 a_set.discard(6)


 ### 数据结构的一些技巧
 #对列表里的元素进行排序
 num_list = [6,2,1,3,4,7,5]
 print(sorted(num_list)) #sorted 函数按照长短、大小、英文字母的顺序给每个列表中的元素进行排序。sorted并不会改列表本身，对列表进行复制，然后进行顺序的整理。
 
 #使用默认参数reverse后列表可以按照逆序整理：
 sorted(num_list,reverse=True)
 