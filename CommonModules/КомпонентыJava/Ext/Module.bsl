﻿
///////////////////////////////////////////////////////////////////////////////
// РАБОТА С JAR-ФАЙЛАМИ

#Область РаботаCJARФайлами

// Функция для подготовки компоненты (записи файлов)
//
// Параметры:
//  Компонента		 - СправочникСсылка.КомпонентыJava - Компонента
//  ОписаниеОшибки	 - Строка, Неопределено - Описание будет заполнено в случае возникновения ошибки
// 
// Возвращаемое значение:
//  Файл - Сохраненный JAR-файл
//
Функция ПодготовитьКомпоненту(Компонента, ОписаниеОшибки = Неопределено)
		
	ФайлJar = Неопределено;
	
	Расположение = Компонента.Расположение;	
	Если НЕ ЗначениеЗаполнено(Расположение) Тогда
		Расположение = КаталогВременныхФайлов();
	КонецЕсли;
	
	Имя = Неопределено;
	Если Компонента.Предопределенный Тогда
		Имя = Компонента.ИмяПредопределенныхДанных;			
		Если ЗначениеЗаполнено(Имя) Тогда		
			Если Метаданные.Справочники.КомпонентыJava.Макеты.Найти(Имя) = Неопределено Тогда
				ВызватьИсключение НСтр("ru = 
					|'Отсутствует установленная в системе компонента. 
					|Воспользуйтесь режимом сравнения/объединения конфигураций'");
			КонецЕсли;
						
			Попытка
				ДвоичныеДанные = Справочники.КомпонентыJava.ПолучитьМакет(Имя);			
				ДвоичныеДанные.Записать(Расположение + Имя + ".jar");
				ФайлJar = Новый Файл(Расположение + Имя + ".jar");
			Исключение
				ОписаниеОшибки = ОписаниеОшибки();
			КонецПопытки;
		КонецЕсли;
	КонецЕсли;
		
	Возврат ?(ФайлJar <> Неопределено И ФайлJar.Существует(), ФайлJar, Неопределено);
	
КонецФункции

// Функция для запуска JAR-файла
//
// Параметры:
//  Компонента		 - СправочникСсылка.КомпонентыJava - Компонента
//  ОписаниеОшибки	 - Строка, Неопределено - Описание будет заполнено в случае возникновения ошибки
// 
// Возвращаемое значение:
//  Булево - Результат запуска компоненты
//
Функция ЗапуститьКомпоненту(Компонента, ОписаниеОшибки = Неопределено) Экспорт
	
	Результат = Ложь;
	
	СистемнаяИнформация = Новый СистемнаяИнформация();	
	ЭтоWindows = СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86 
		ИЛИ СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86_64;
		
	ИмяФайлаJava = "";
	JAVA_HOME = ПолучитьJAVA_HOME();	
	Если ЗначениеЗаполнено(JAVA_HOME) Тогда
		// Запуск на указанной версии JRE					
		Если ЭтоWindows Тогда
			ИмяФайлаJava = JAVA_HOME + "\bin\java.exe"; 
		Иначе
			ИмяФайлаJava = JAVA_HOME + "/bin/java";	
		КонецЕсли;	
		
		ФайлJava = Новый Файл(ИмяФайлаJava);		
		Если Не ФайлJava.Существует() Тогда
			ОписаниеОшибки = НСтр("ru = 'Проверьте настройки JAVA_HOME (Управление компонентой)'");			
		КонецЕсли;		
	Иначе
		// Запуск на машине "по умолчанию"		
		ИмяФайлаJava = "java";
	КонецЕсли;
	
	JarФайл = ПодготовитьКомпоненту(Компонента, ОписаниеОшибки);
	Если JarФайл <> Неопределено И JarФайл.Существует() Тогда
		ПолноеИмяJarФайла = JarФайл.ПолноеИмя;
		Если ЭтоWindows Тогда
			ПолноеИмяJarФайла = """" + JarФайл.ПолноеИмя + """";
			ИмяФайлаJava = """" + ИмяФайлаJava + """";
		КонецЕсли;	
		СтрокаКоманды = ИмяФайлаJava + " -jar " + ПолноеИмяJarФайла + " -p " + Формат(ПолучитьПорт(Компонента), "ЧГ=0");
		ЗапуститьПриложение(СтрокаКоманды, , Ложь);
		Результат = Истина;
	Иначе
		ОписаниеОшибки = НСтр("ru = 'Исполняемый файл компоненты не найден'");	
	КонецЕсли;			
		
	Возврат Результат;
			
КонецФункции

// Функция для остановки компоненты (kill)
//
// Параметры:
//  Компонента		 - СправочникСсылка.КомпонентыJava - Компонента
// 
// Возвращаемое значение:
//   - 
//
Функция ОстановитьКомпоненту(Компонента) Экспорт
	
	СистемнаяИнформация = Новый СистемнаяИнформация();
	
	// Linux
	Если СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Linux_x86 ИЛИ
		СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Linux_x86_64 Тогда
		
		ИмяФайла = ПолучитьИмяВременногоФайла(".txt");
		Команда = "lsof -i tcp:" + Формат(ПолучитьПорт(Компонента), "ЧГ=0") + " > " + ИмяФайла;
		ЗапуститьПриложение(Команда, , Истина);
		
		Чтение = Новый ЧтениеТекста(ИмяФайла);
		Данные = Новый Массив();
		Строка = Чтение.ПрочитатьСтроку();
		Пока Строка <> Неопределено Цикл
			Данные.Добавить(Строка);
			Строка = Чтение.ПрочитатьСтроку();
		КонецЦикла;		
		Если Данные.Количество() = 2 Тогда
			Слова = РазложитьСтрокуВМассивПодстрок(Данные[1], " ");
			Если Слова.Количество() > 2 Тогда
				Если Слова[0] = "java" Тогда
					ЗапуститьПриложение("kill " + Слова[1], , Истина);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Чтение.Закрыть();
		
		УдалитьФайлы(ИмяФайла);
				
	// Windows
	ИначеЕсли СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86 ИЛИ
		СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86_64 Тогда
		
		ИмяФайла = ПолучитьИмяВременногоФайла(".txt");
		Команда = "cmd /c netstat -ano | findstr " + Формат(ПолучитьПорт(Компонента), "ЧГ=0") + " > " + """" + ИмяФайла + """";
		ЗапуститьПриложение(Команда, , Истина);
		
		Чтение = Новый ЧтениеТекста(ИмяФайла);
		Данные = Новый Массив();
		Строка = Чтение.ПрочитатьСтроку();
		Пока Строка <> Неопределено Цикл
			Данные.Добавить(Строка);
			Строка = Чтение.ПрочитатьСтроку();
		КонецЦикла;	
		
		Если Данные.Количество() > 0 Тогда
			Для Каждого Строка Из Данные Цикл
				Слова = РазложитьСтрокуВМассивПодстрок(Строка, " ");
				Если Слова.Количество() > 4 Тогда
					Если Слова[4] <> "0" И СтрНайти(Слова[1], Формат(ПолучитьПорт(Компонента), "ЧГ=0")) <> 0 Тогда
						ЗапуститьПриложение("taskkill /F /PID " + Слова[4], , Истина);
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		Чтение.Закрыть();
		
		УдалитьФайлы(ИмяФайла);
				
	// MacOS
	ИначеЕсли СистемнаяИнформация.ТипПлатформы = ТипПлатформы.MacOS_x86 ИЛИ
		СистемнаяИнформация.ТипПлатформы = ТипПлатформы.MacOS_x86_64 Тогда
		
	КонецЕсли;
	
КонецФункции

// Функция для получения порта компоненты (если не задан, то по умолчанию)
//
// Параметры:
//  Компонента	 - СправочникСсылка.КомпонентыJava - Компонента
// 
// Возвращаемое значение:
//  Число - 
//
Функция ПолучитьПорт(Компонента) Экспорт
	
	Порт = Компонента.Порт;
	Если НЕ ЗначениеЗаполнено(Порт) Тогда
		Порт = КомпонентыJavaКлиентСервер.ПортКомпонентыПоУмолчанию(Компонента);
	КонецЕсли;
	
	Возврат Порт;
			
КонецФункции

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// JRE

#Область ВиртуальныеМашины

Функция ДоступныеJRE() Экспорт
	
	Результат = Новый Массив();
			
	// Windows
	СистемнаяИнформация = Новый СистемнаяИнформация();
	
	ЭтоWindows = СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86_64 
		ИЛИ СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86;
		
	ЭтоLinux = СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Linux_x86_64
		ИЛИ СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Linux_x86;
		
	КаталогиПоиска = Новый Массив();
	КаталогиПоиска.Добавить("C:\Program Files\Java");
	КаталогиПоиска.Добавить("C:\Program Files (x86)\Java");
	КаталогиПоиска.Добавить("/usr/local");
	КаталогиПоиска.Добавить("/usr/lib/jvm");
		
	binJava = Неопределено;		
	Если ЭтоWindows Тогда	
		binJava = "\bin\java.exe";		
	ИначеЕсли ЭтоLinux Тогда
		binJava = "/bin/java";		
	Иначе
		Возврат Результат;
	КонецЕсли;
	
	Для Каждого КаталогПоиска Из КаталогиПоиска Цикл
		НайденныеФайлы = НайтиФайлы(КаталогПоиска, "j*", Ложь);
		Для Каждого НайденныйФайл Из НайденныеФайлы Цикл
			
			Если СтрНачинаетсяС(НайденныйФайл.Имя, "jdk") 
				ИЛИ СтрНачинаетсяС(НайденныйФайл.Имя, "jre") 
				ИЛИ СтрНачинаетсяС(НайденныйФайл.Имя, "java") Тогда
				
				ФайлJava = Новый Файл(НайденныйФайл.ПолноеИмя + binJava);
				Если ФайлJava.Существует() Тогда
					Результат.Добавить(НайденныйФайл.ПолноеИмя);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Получение расположения JRE
// 
// Возвращаемое значение:
//  Строка - Значение константы JAVA_HOME
//
Функция ПолучитьJAVA_HOME() Экспорт
	
	Возврат Константы.JAVA_HOME.Получить();
	
КонецФункции

// Установка расположения JRE
//
// Параметры:
//  Значение - Строка - Распложение JRE
//
Процедура УстановитьJAVA_HOME(Значение) Экспорт
	
	Константы.JAVA_HOME.Установить(Значение);
	
КонецПроцедуры

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// API (Info)

#Область API_Info

Функция ПроксиКомпоненты(Компонента, ОписаниеОшибки = Неопределено, ПопыткаПодключения = 1) Экспорт
	
	Прокси = Неопределено;	
	Попытка
		АдресWSDL =                                            
			"http://127.0.0.1:" + Формат(ПолучитьПорт(Компонента), "ЧГ=0") + "/InfoService?wsdl";		
		Определение = Новый WSОпределения(АдресWSDL);	
		Прокси = Новый WSПрокси(Определение, "http://info.ak.ru/", "Info", "InfoPort");
	Исключение
		Если ПопыткаПодключения = 1 Тогда
			// Попытка запуска
			Если НЕ ЗапуститьКомпоненту(Компонента, ОписаниеОшибки) Тогда
				Возврат Прокси;			
			КонецЕсли;			
		ИначеЕсли ПопыткаПодключения > 1000 Тогда
			Возврат Прокси;
		КонецЕсли;
		
		Прокси = ПроксиКомпоненты(Компонента, ОписаниеОшибки, ПопыткаПодключения + 1);
	КонецПопытки;
			
	Возврат Прокси;
	
КонецФункции

Функция КомпонентаДоступна(Компонента) Экспорт
	
	Прокси = Неопределено;	
	Попытка
		АдресWSDL = 
			"http://127.0.0.1:" + Формат(ПолучитьПорт(Компонента), "ЧГ=0") + "/InfoService?wsdl";		
		Определение = Новый WSОпределения(АдресWSDL);	
		Прокси = Новый WSПрокси(Определение, "http://info.ak.ru/", "Info", "InfoPort");
	Исключение
	
	КонецПопытки;
		
	Возврат Прокси <> Неопределено;
	
КонецФункции

Функция ВерсияКомпоненты(Компонента, ОписаниеОшибки = Неопределено) Экспорт
	
	Версия = НСтр("ru = 'API компоненты не доступно.'");;	
	
	Прокси = ПроксиКомпоненты(Компонента, ОписаниеОшибки);
	Если Прокси <> Неопределено Тогда		
		Версия = Прокси.version();	
	КонецЕсли;			
	
	Возврат Версия;
		
КонецФункции

Функция ИсторияИзмененийКомпоненты(Компонента, ОписаниеОшибки = Неопределено) Экспорт
	
	Результат = Новый Массив();
	
	Прокси = ПроксиКомпоненты(Компонента, ОписаниеОшибки);
	Если Прокси <> Неопределено Тогда		
		ИсторияИзменений = Прокси.details();
		Для Каждого Запись Из ИсторияИзменений.builds Цикл
			Результат.Добавить(
				Новый Структура("Версия, Описание", Запись.Version, Запись.Description));	
		КонецЦикла;
	КонецЕсли;			
	
	Возврат Результат;
		
КонецФункции

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

#Область СлужебныеПроцедурыИФункции

// Получение компонент, для которых при объединении конфигурации были 
//  выбраны соответствующие макеты
// 
// Возвращаемое значение:
//  Массив -  
//
Функция УстановленныеКомпоненты() Экспорт
	
	Результат = Новый Массив();
	
	Запрос = Новый Запрос();
	Запрос.Текст =
		"ВЫБРАТЬ
		|	КомпонентыJava.Ссылка,
		|	КомпонентыJava.ИмяПредопределенныхДанных
		|ИЗ
		|	Справочник.КомпонентыJava КАК КомпонентыJava
		|ГДЕ
		|	КомпонентыJava.Предопределенный";
	
	РезультатЗапроса = Запрос.Выполнить();
	Если Не РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		
		Макеты = Метаданные.Справочники.КомпонентыJava.Макеты;
		Пока Выборка.Следующий() Цикл		
			Если Макеты.Найти(Выборка.ИмяПредопределенныхДанных) <> Неопределено Тогда
				Результат.Добавить(Выборка.Ссылка);
			КонецЕсли;			
		КонецЦикла;
	КонецЕсли;
		
	Возврат Результат;
	
КонецФункции

// Разбивает строку на несколько строк по разделителю. Разделитель может иметь любую длину.
//
// Параметры:
//  Строка                 - Строка - текст с разделителями;
//  Разделитель            - Строка - разделитель строк текста, минимум 1 символ;
//  ПропускатьПустыеСтроки - Булево - признак необходимости включения в результат пустых строк.
//    Если параметр не задан, то функция работает в режиме совместимости со своей предыдущей версией:
//     - для разделителя-пробела пустые строки не включаются в результат, для остальных разделителей пустые строки
//       включаются в результат.
//     - если параметр Строка не содержит значащих символов или не содержит ни одного символа (пустая строка), то в
//       случае разделителя-пробела результатом функции будет массив, содержащий одно значение "" (пустая строка), а
//       при других разделителях результатом функции будет пустой массив.
//  СокращатьНепечатаемыеСимволы - Булево - сокращать непечатаемые символы по краям каждой из найденных подстрок.
//
// Возвращаемое значение:
//  Массив - массив строк.
//
// Примеры:
//  РазложитьСтрокуВМассивПодстрок(",один,,два,", ",") - возвратит массив из 5 элементов, три из которых  - пустые строки;
//  РазложитьСтрокуВМассивПодстрок(",один,,два,", ",", Истина) - возвратит массив из двух элементов;
//  РазложитьСтрокуВМассивПодстрок(" один   два  ", " ") - возвратит массив из двух элементов;
//  РазложитьСтрокуВМассивПодстрок("") - возвратит пустой массив;
//  РазложитьСтрокуВМассивПодстрок("",,Ложь) - возвратит массив с одним элементом "" (пустой строкой);
//  РазложитьСтрокуВМассивПодстрок("", " ") - возвратит массив с одним элементом "" (пустой строкой);
//
Функция РазложитьСтрокуВМассивПодстрок(Знач Строка, Знач Разделитель = ",", Знач ПропускатьПустыеСтроки = Неопределено, СокращатьНепечатаемыеСимволы = Ложь) Экспорт
	
	Результат = Новый Массив;
	
	// для обеспечения обратной совместимости
	Если ПропускатьПустыеСтроки = Неопределено Тогда
		ПропускатьПустыеСтроки = ?(Разделитель = " ", Истина, Ложь);
		Если ПустаяСтрока(Строка) Тогда 
			Если Разделитель = " " Тогда
				Результат.Добавить("");
			КонецЕсли;
			Возврат Результат;
		КонецЕсли;
	КонецЕсли;
	//
	
	Позиция = Найти(Строка, Разделитель);
	Пока Позиция > 0 Цикл
		Подстрока = Лев(Строка, Позиция - 1);
		Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Подстрока) Тогда
			Если СокращатьНепечатаемыеСимволы Тогда
				Результат.Добавить(СокрЛП(Подстрока));
			Иначе
				Результат.Добавить(Подстрока);
			КонецЕсли;
		КонецЕсли;
		Строка = Сред(Строка, Позиция + СтрДлина(Разделитель));
		Позиция = Найти(Строка, Разделитель);
	КонецЦикла;
	
	Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Строка) Тогда
		Если СокращатьНепечатаемыеСимволы Тогда
			Результат.Добавить(СокрЛП(Строка));
		Иначе
			Результат.Добавить(Строка);
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции 


///////////////////////////////////////////////////////////////////////////////
// JSON - Объект

Функция ОбъектИзJSON(СтрокаJSON) Экспорт
	
	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(СтрокаJSON);

	Результат = ПрочитатьJSON(ЧтениеJSON);
		
	ЧтениеJSON.Закрыть();
	
	Возврат Результат;
	
КонецФункции

Функция ОбъектВJSON(Объект, ПереносСтрок = Истина) Экспорт
	
	ЗаписьJSON = Новый ЗаписьJSON();
	ЗаписьJSON.ПроверятьСтруктуру = Ложь;
	ПараметрыЗаписиJSON = Новый ПараметрыЗаписиJSON(
		?(ПереносСтрок, ПереносСтрокJSON.Авто, ПереносСтрокJSON.Нет), 
		Символы.Таб);
	
	ЗаписьJSON.УстановитьСтроку(ПараметрыЗаписиJSON);
	ЗаписатьJSON(ЗаписьJSON, Объект);
	РезультатJSON = ЗаписьJSON.Закрыть();
	
	Возврат РезультатJSON;
	
КонецФункции

#КонецОбласти
