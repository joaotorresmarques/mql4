//+------------------------------------------------------------------+
//|                                             PauseBeforeTrade.mq4 |
//|                                      Copyright © 2006, komposter |
//|                                      mailto:komposterius@mail.ru |
//+------------------------------------------------------------------+
//#property copyright "Copyright © 2006, komposter"
//#property link      "mailto:komposterius@mail.ru"

extern int PauseBeforeTrade = 10; // пауза между торговыми операциями (в секундах)

/////////////////////////////////////////////////////////////////////////////////
// int _PauseBeforeTrade ()
//
// Функция устанавливает глобальной переменной LastTradeTime значение локального времени.
// Если в момент запуска локальное время меньше, чем значение LastTradeTime + PauseBeforeTrade, функция ждёт.
// Если глобальной переменной LastTradeTime не существует, функция создаёт её.
// Коды возвратов:
//  1 - успешное завершение
// -1 - работа эксперта была прервана пользователем (эксперт удалён с графика, закрыт терминал, изменился период 
// или символ графика, ... )
/////////////////////////////////////////////////////////////////////////////////
int _PauseBeforeTrade ()
{
	// при тестировании нет смысла выдерживать паузу - просто завершаем работу функции
	if ( IsTesting() ) { return(1); }
	int _GetLastError = 0;
	int _LastTradeTime, RealPauseBeforeTrade;

	//+------------------------------------------------------------------+
	//| Проверяем, существует ли гл. переменная и, если нет, создаём её  |
	//+------------------------------------------------------------------+
	while( true )
	{
		// если эксперт был остановлен пользователем, прекращаем работу
		if ( IsStopped() ) { Print( "Эксперт был остановлен пользователем!" ); return(-1); }

		// проверяем, существует ли гл. переменная
		// если она есть, выходим из этого цикла
		if ( GlobalVariableCheck( "LastTradeTime" ) ) break;
		else
		// если GlobalVariableCheck вернула FALSE, значит либо переменной нет, либо при проверке возникла ошибка
		{
			_GetLastError = GetLastError();
			// если это всё таки ошибка, выводим информацию, ждём 0,1 секунды и начинаем проверку сначала
			if ( _GetLastError != 0 )
			{
				Print( "_PauseBeforeTrade() - GlobalVariableCheck( \"LastTradeTime\" ) - Error #", _GetLastError );
				Sleep(100);
				continue;
			}
		}

		// если ошибки нет, значит глобальной переменной просто нет, пытаемся создать её
		// если GlobalVariableSet > 0, значит глобальная переменная успешно создана. Выходим из ф-ции
		if ( GlobalVariableSet( "LastTradeTime", LocalTime() ) > 0 ) return(1);
		else
		// если GlobalVariableSet вернула значение <= 0, значит при создании переменной возникла ошибка
		{
			_GetLastError = GetLastError();
			// выводим информацию, ждём 0,1 секунды и начинаем попытку сначала
			if ( _GetLastError != 0 )
			{
				Print( "_PauseBeforeTrade() - GlobalVariableSet ( \"LastTradeTime\", ", LocalTime(), " ) - Error #", _GetLastError );
				Sleep(100);
				continue;
			}
		}
	}

 
	//+---------------------------------------------------------------------------------------+
	//| Если выполнение функции дошло до этого места, значит глобальная переменная существует.|
	//| Ждём, пока LocalTime() станет > LastTradeTime + PauseBeforeTrade                      |
	//+---------------------------------------------------------------------------------------+
	while( true )
	{
		// если эксперт был остановлен пользователем, прекращаем работу
		if ( IsStopped() ) { Print( "Эксперт был остановлен пользователем!" ); return(-1); }

		// получаем значение гл. переменной
		_LastTradeTime = GlobalVariableGet ( "LastTradeTime" );
		// если при этом возникает ошибка, выводим информацию, ждём 0,1 секунды и начинаем попытку сначала
		_GetLastError = GetLastError();
		if ( _GetLastError != 0 )
		{
			Print( "_PauseBeforeTrade() - GlobalVariableGet ( \"LastTradeTime\" ) - Error #", _GetLastError );
			continue;
		}

		// считаем, сколько прошло секунд со времени последней торговой операции
		RealPauseBeforeTrade = LocalTime() - _LastTradeTime;
		
		// если прошло меньше, чем PauseBeforeTrade секунд,
		if ( RealPauseBeforeTrade < PauseBeforeTrade )
		{
			// выводим информацию, ждём секунду, и проверяем снова
			Comment( "Пауза между торговыми операциями. Осталось ", PauseBeforeTrade - RealPauseBeforeTrade, " сек." );
			Sleep(1000);
			continue;
		}
		// если прошло больше, чем PauseBeforeTrade секунд, останавливаем выполнения цикла
		else
		{ break; }
	}

	//+---------------------------------------------------------------------------------------+
	//| Если выполнение функции дошло до этого места, значит глобальная переменная существует,|
	//| и локальное время больше, чем LastTradeTime + PauseBeforeTrade							   |
	//| Устанавливаем глобальной переменной LastTradeTime значение локального времени         |
	//+---------------------------------------------------------------------------------------+
	while( true )
	{
		// если эксперт был остановлен пользователем, прекращаем работу
		if ( IsStopped() ) { Print( "Эксперт был остановлен пользователем!" ); return(-1); }

		// Устанавливаем глобальной переменной LastTradeTime значение локального времени. Если успешно - выходим
		if ( GlobalVariableSet( "LastTradeTime", LocalTime() ) > 0 ) { Comment( "" ); return(1); }
		else
		// если GlobalVariableSet вернула значение <= 0, значит возникла ошибка
		{
			_GetLastError = GetLastError();
			// выводим информацию, ждём 0,1 секунды и начинаем попытку сначала
			if ( _GetLastError != 0 )
			{
				Print( "_PauseBeforeTrade() - GlobalVariableSet ( \"LastTradeTime\", ", LocalTime(), " ) - Error #", _GetLastError );
				Sleep(100);
				continue;
			}
		}
	}
}

