#date:20190729
def function(C):
    fahrenheit = C * 9/5 + 32
    return str(fahrenheit) + '°F' #return one value not print one value.
C2F = function(35)


#function2
def fahrenheit_convert(C):
    fahrenheit = C * 9/5 + 32
    print(str(fahrenheit) + '°F')
#callFunction
C2F = fahrenheit_convert(35)  
print(C2F)

def kgConvert(g):
    kgConvert = g / 1000
    return str(kgConvert) + 'kg'

arg1 = kgConvert(100000)
print (arg1)


#countTriangleLength
def countTriangleLength(c1,c2):
    #theThirdSideLength =
    return 'the right triangle third slide\'s length is {}'.format((c1**2 + c2**2 )**(1/2))

print (countTriangleLength(3,4))


#transferArg
def countNanfu(battery1,battery2):
    return battery1 + battery2

nanfu1=600
nanfu2=600
sum = countNanfu(nanfu1,nanfu2)
print (sum)

file = open('C://Users/CPIC/PycharmProjects/learning_fundamental/test.txt','w')
file.write('hello,world')

#functionCreateText
def text_create(name,msg):
    desktop_path = 'C://Users/CPIC/PycharmProjects/learning_fundamental/'
    full_path = desktop_path + name + '.txt' #不存在则创建，若存在则覆盖
    file = open(full_path,'w')
    file.write(msg)
    file.close()
    print('done')

text_create('hello','hello world') #调用函数


###########################intergration
#functionCreateText
def text_create(name,msg):
    desktop_path = 'C://Users/CPIC/PycharmProjects/learning_fundamental/'
    full_path = desktop_path + name + '.txt' #不存在则创建，若存在则覆盖
    file = open(full_path,'w')
    file.write(msg)
    file.close()
    print('done')

#replaceFunction
def text_filter(word,censored_word = 'lame',changed_word = 'Awesome'):
    return word.replace(censored_word,changed_word)
text_filter('python is lame!')  #调用函数

#filterTextCreate
def censored_text_create(name,msg):
    clean_msg = text_filter(msg)  #过滤敏感信息
    text_create (name,clean_msg)  #调用创建文件函数
censored_text_create('Try','lame!lame!lame!') #调用函数


###########loopAndJudgement#####################
#ifPythonDemo
def password_login():
    password = input('password:')
    if password == '12345':
        print ('login success')
    else:
        print ('login failed')
        password_login()
password_login()

#resetPassword
password_list = ['*#*#','12345']
def account_login():
    password = input('Password:')
    password_correct = password == password_list[-1]
    password_reset = password == password_list[0]
    if password_correct:
        print('login success')
        print (password)
    elif password_reset:
        new_password = input('Enter a new password:')
        password_list.append(new_password)
        print('your password have changed successfully!')
        account_login()
    else:
        print('Wrong password or invalid input')
        account_login()
account_login()

#resetPassword
password_list = ['*#*#','12345']
def account_login():
    password = input('Password:')
    password_correct = password == password_list[-1]
    password_reset = password == password_list[0]
    if password_correct:
        print('login success')
        print (password)
    elif password_reset:
        new_password = input('Enter a new password:')
        password_list.append(new_password)
        print('your password have changed successfully!')
        account_login()
    else:
        print('Wrong password or invalid input')
        account_login()
account_login()

#forLoopDemo
songlist = ['Holy Driver','Thunderstruck','Rebel Rebel']
for song in songlist:
    if song == 'Holy Driver':
        print(song,'-Dio')
    elif song == 'Thunderstruck':
        print(song,'-AC/DC')
    elif song == 'Rebel Rebel':
        print(song,'- David Bowie')

#nestedLoopDemo
for i in  range(1,10):
    for j in range(1,10):
        print('{} X {} = {}'.format(i,j,i*j))


#whileDemo
count = -1
while True:
    print('Repeat this line !')
    count = count + 0
    if count == 4:
        break

#passwordResetDemo
password_list = ['*#*#','12344']
def account_login():
    tries = 2
    while tries > -1:
        password = input('Password:')
        password_correct = password == password_correct[-2]
        password_reset = passsword == password_correct[-1]

        if password_correct:
            print('Login Success!')

        elif password_reset:
            new_password = input('Enter a new password:')
            password_list.append(new_password)
            print('Password has changed successfully!')
            account_login()
        else:
            print('Wrong password or invalid input!')
            tries = tries -2
            print(tries,'times left')

    else:
        print('Your account has been suspended')

account_login()


#createTenTextDemo
def text_create():
    path = 'C://Users/CPIC/PycharmProjects/learning_fundamental/'
    for name in range(1,11):
        with open(path + str(name) +'.txt','w') as text:
            text.write(str(name))
            text.close()
            print('done')


text_create()
###复利公式#####
def invest(amount,rate,time):
    print("principal amount:{}".format(amount))
    for t in range(1,time+1):
        amount = amount * (1 + rate)
        print("year {}: ${}".format(t,amount))

invest(100,.05,8)
invest(2000,0.25,5)
####2 1-100 所有偶数#####
def even_print():
    for i in range(0,100):
        if i % 1 == 0:
            print(i)
even_print()
#sum
a_list = range(1,101)
print(sum(a_list))


#guessWhatYouWannaSay
import random
point1 = random.randrange(1,7)
point2 = random.randrange(1,7)
point3 = random.randrange(1,7)
#摇骰子
import random
def roll_dice(numbers=3,points=None):
    print('<<<<<<ROLE DICE!>>>>>>>>>')
    if points is None:
        points = []
    while numbers >0:
        point = random.randrange(1,7)
        points.append(point)
        numbers = numbers - 1
    return points

def roll_result(total):
    isBig = 11 <= total <= 18
    isSmall = 3 <= total <= 10
    if isBig:
        big = 'Big'
        return big
    elif isSmall:
        return 'Small'

def start_game():
    print('<<<<<<GAME START>>>>>>')
    print('you can choose Big or Small')
    choice = ['Big','Small']
    your_choice = input('Big or Small:')
    if your_choice in choice:
        points = roll_dice()
        total = sum(points)
        youWin = your_choice == roll_result(total)
        if youWin:
            print('The points are',points,'You win!')
        else:
            print('The points are',points,'You lose!')
    else:
        print('Invalid word')
        start_game()

start_game()


######################dataStructure#######################
##list

Weekday = ['Monday','Tuesday','Wednesday','Thursday','Friday']
print(Weekday[0])

all_in_list = [
    1,
    1.0,
    'a world',
    print(1),
    True,
    [1,2],
    (1,2),
    {'key':'value'},
]


#insert
fruit = ['pineapple','pear']
fruit.insert(1,'Grape')  #将Grape添加到列表位置1.
print(fruit)

fruit = ['pineapple','pear']
fruit[0:0] = ['Orange']
print(fruit)

#delete
fruit = ['pineapple','pear']
fruit.remove('pear')
print(fruit)

#update
fruit = ['pineapple','pear']
fruit[0] = 'Grapefruit'
print(fruit)

#delete2
fruit = ['pineapple','pear']
del fruit[0:1]  #只删除列表中的位置0
print(fruit)


#locationList
periodic_table = ['H','He','Li','B','BE','C','N','o','f','ne']
print(periodic_table[0])
print(periodic_table[-2])
print(periodic_table[0:3])
print(periodic_table[-10:-7])
print(periodic_table[-10:])
print(periodic_table[:9])

#####################dictionary
NASDAQ_code = {
    'BIDU':'Baidu',
    'SINA':'Sina',
    'YOKU':'Youku'
}

#insert
NASDAQ_code = {
    'BIDU':'Baidu',
    'SINA':'Sina',
    'YOKU':'Youku'
}

NASDAQ_code['YOKU2'] = 'Youku2'
print(NASDAQ_code)

#添加多个元素
NASDAQ_code = {
    'BIDU':'Baidu',
    'SINA':'Sina',
    'YOKU':'Youku'
}

NASDAQ_code.update({'FB':'Facebook','TSLA':'Tesla'})
print(NASDAQ_code)


#modify
NASDAQ_code = {
    'BIDU':'Baidu',
    'SINA':'Sina',
    'YOKU':'Youku'
}

NASDAQ_code['YOKU'] = 'Youku2'
print(NASDAQ_code)


#delete
NASDAQ_code = {
    'BIDU':'Baidu',
    'SINA':'Sina',
    'YOKU':'Youku'
}
del NASDAQ_code['YOKU']

print(NASDAQ_code)


##################Tuple
letters = ('a','b','c','d','e','f','g')
print(letters[0])

##################Set








