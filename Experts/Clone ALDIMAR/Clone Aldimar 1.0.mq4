/*========DESCRIÇÃO CUZAO 1.0====== (CLONE DO AGRESSOR)
   1.RSI da o sinal quando chegar em 10 ou 90
   2.Se RSI <10 BUY || Se RSI>90 SHELL
   3. TAKE de 1 ou 2 Pips
   4. STOP de 1 ou 2 Pips
=======================*/


/*=======================================================ANOTAÇÕES========================================================
   Verificar a CONTA ZERO XM. que segundo o site spred menor que 1PIP. 
   
   Realizar função de Lots, dependendo do dinheiro da banca aumentar progressivo.
   
   A função do Lot é conforme quanto tem na conta. O EA agressor utiliza numeros quebrados para definir o valor do lote.
   O EA XX_Calculadoralote faz esse papel tranquilamente. 

========================================================================================================================*/

input int MagicNumber = 8008;
input int Lots = 1.0;
input int Slippage = 0;
input int Periodo = 4;
input int TF = 5;

input int TAKE = 10;
input int STOP = 20;

int ticket;
double lot,mrg;


   
int OnInit()
 {



return(INIT_SUCCEEDED);

 }




void OnTick()
  {
      //========================POINT===============================
               double MyPoint=Point;                                      
               if(Digits==3 || Digits==5) MyPoint=Point*10;               
      //============================================================
      
      double RSI = iRSI(Symbol(),NULL,Periodo,PRICE_CLOSE,1);
       double BBupper = iBands(Symbol(),NULL,22,2,0,PRICE_CLOSE,MODE_UPPER,0);
     double BBlower = iBands(Symbol(),NULL,22,2,0,PRICE_CLOSE,MODE_LOWER,0);
      
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++       
    if(OrdersTotal()==0)
    {

      if(High[0]-20*MyPoint >BBupper )
      {
           ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,0,NULL,MagicNumber,0,Red);
      }
      
      /*else if(High[0]-4*MyPoint ==Open[0] || High[0]-4*MyPoint == Close[0])
      {
            if(RSI>86)  ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,0,NULL,MagicNumber,0,Red);
      } */     
         
      
    }//fim ORDERSTOTAL 
      
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++DEFINIÇÃO STOP E TAKE++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++      
   
     int cntt, totalt=OrdersTotal();
     for(cntt=0;cntt<totalt;cntt++)
     {
         if(OrderSelect(cntt,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {
            if(OrderType()==OP_BUY)
            {
               ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-STOP*MyPoint,OrderOpenPrice()+TAKE*MyPoint,0,0);
            }//FIM OP_BUY
            
            if(OrderType()==OP_SELL)
            {
               ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+STOP*MyPoint,OrderOpenPrice()-TAKE*MyPoint,0,0);
            }//FIM OP_SELL   
  
         }//FIM MAGIC
     }//FIM CONTADOR    
  
  
  
  
  }
