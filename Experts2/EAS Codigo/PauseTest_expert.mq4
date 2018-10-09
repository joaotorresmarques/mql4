//+------------------------------------------------------------------+
//|                                                    PauseTest.mq4 |
//|                                      Copyright © 2006, komposter |
//|                                      mailto:komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, komposter"
#property link      "mailto:komposterius@mail.ru"

#include <PauseBeforeTrade.mq4>
#include <TradeContext.mq4>

int ticket = 0;
int start()
{
	// если нет позиции, открытой этим экспертом
	if ( ticket <= 0 )
	{
		// ждём освобождения торгового потока и занимаем его (если произошла ошибка, выходим)
		if ( TradeIsBusy() < 0 ) { return(-1); }
		// выдерживаем паузу между торговыми операциями
		if ( _PauseBeforeTrade() < 0 )
		{
			// если произошла ошибка, освобождаем торговый поток и выходим
			TradeIsNotBusy();
			return(-1);
		}
		// обновляем рыночную информацию
		RefreshRates();

		// и пытаемся открыть позицию
		ticket = OrderSend( Symbol(), OP_BUY, 0.1, Ask, 5, 0.0, 0.0, "PauseTest", 123, 0, Lime );
		if ( ticket < 0 ) { Alert( "Ошибка OrderSend № ", GetLastError() ); }
		// освобождаем торговый поток
		TradeIsNotBusy();
	}
	// если есть позиция, открытая этим экспертом
	else
	{
		// ждём освобождения торгового потока и занимаем его (если произошла ошибка, выходим)
		if ( TradeIsBusy() < 0 ) { return(-1); }
		// выдерживаем паузу между торговыми операциями
		if ( _PauseBeforeTrade() < 0 )
		{
			// если произошла ошибка, освобождаем торговый поток и выходим
			TradeIsNotBusy();
			return(-1);
		}
		// обновляем рыночную информацию
		RefreshRates();

		// и пытаемся закрыть позицию
		if ( !OrderClose( ticket, 0.1, Bid, 5, Lime ) )
		{ Alert( "Ошибка OrderClose № ", GetLastError() ); }
		else
		{ ticket = 0; }

		// освобождаем торговый поток
		TradeIsNotBusy();
	}
return(0);
}

