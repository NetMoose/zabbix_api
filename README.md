## Обвязка для доступа к Zabbix API

Данный класс написан для простого доступа к Zabbix API [описанному в документации](https://www.zabbix.com/documentation/3.4/ru/manual/api). 

### Использование в скриптах

Для использования класса необходимо вставить в код:
```
Using Module ZabbixAPI
```
Создание класса 
```
$zbx = [ZabbixAPI]::new('http','zabbix.lab.mts.ru','forauto','1qaz!QAZ',$true)
```
где параметры 
1. *'http'* или *'https'* (возможно передать пустую строку) - это протокол для доступа к серверу заббикс
2. Адрес сервера
3. Логин для доступа к API
4. Пароль для доступа к API
5. $true, $false или $null - выводить ли дебаг-сообщения с JSON, передаваемым API

Созданный класс \$zbx в конструкторе заполняет первоначально поля запроса ($zbx.query), преобразовывает его в JSON для вызова авторизации и получения токена для доступа к методам API. 
Полученный токен сохраняется в поле $zbx.query.auth и в дальнейшем используется в вызовах API для аутентификации.

Дальнейшие вызовы производятся в следующей последовательности:
1. Заполняем поле $zbx.query.method необходимой командой к API из [справочника методов](https://www.zabbix.com/documentation/3.4/ru/manual/api/reference)
2. Создаем хэш-таблицу параметров вызова функции (см. пример ниже)
3. Вызываем метод $zbx.SendQueryToZabbix() с параметрами из второго шага
4. На выходе получаем массив значений

### Пример

Возьмем [первый пример из справочника](https://www.zabbix.com/documentation/3.4/ru/manual/api/reference/host/get)

Реализация может выглядеть так:

```
Using Module ZabbixAPI

$zbx = [ZabbixAPI]::new('http','zabbix.lab.mts.ru','forauto','1qaz!QAZ',$true)

$zbx.query.method = 'host.get'

$params = @{
    output="extend"
    filter=@{
        host=@( 
            'Zabbix server'
            'Linux server'
            )
    }
}

foreach($h in $zbx.SendQueryToZabbix($params)) {
    $h.name
}
```
