/*========DESCRIÇÃO BB Money 1.0.1====== 
  
=======================*/


/*=======================================================ANOTAÇÕES========================================================
**SISTEMA DA DINHEIRO. na versão 1.0.3 terá a função de aumento de LOT caso MAGIC3 dê stop. =)

O sistema ta dando lucro e as vezes uma perca muito grande.
De acordo com o EA history, se magic4 for negativo então aumentar o LOT1,2,3 para o dobro para recuperar.. quando recuperar 
oq o FAIL deu, então volta ao lot normal. =)

depois estudar Objectset, colocar algumas informações na tela.
========================================================================================================================*/
input int Slippage = 0;
input int MagicNumber1 = 8001;
input int MagicNumber2 = 8002;
input int MagicNumber3 = 8003;

input int Lots1 = 1.0;
input int Lots2 = 2.0;
input int Lots3 = 4.0;

input int TAKE1 = 20; 
input int TAKE2 = 10;
input int TAKE3 = 5;

input int STOP1 = 20;
input int STOP2 = 10; 
input int STOP3 = 30; 

int ticket;


void OnTick()
  {
      //========================POINT===============================
               double MyPoint=Point;                                      
               if(Digits==3 || Digits==5) MyPoint=Point*10;               
      //============================================================
      
     double BBupper = iBands(Symbol(),NULL,22,3,0,PRICE_CLOSE,MODE_UPPER,0);
     double BBlower = iBands(Symbol(),NULL,22,3,0,PRICE_CLOSE,MODE_LOWER,0);
     
      
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++       
   
   if(OrdersTotal()==0)
   {
      if(Ask > BBupper || Bid > BBupper)
      {
         ticket = OrderSend(Symbol(),OP_SELL,Lots1,Bid,Slippage,0,Bid-TAKE1*MyPoint,NULL,MagicNumber1,0,Red);
      }
      
      if(Bid < BBlower || Ask < BBlower)
      {
         ticket = OrderSend(Symbol(),OP_BUY,Lots1,Ask,Slippage,0,Ask+TAKE1*MyPoint,NULL,MagicNumber1,0,Blue);
      }      
  
  }//FIM ORDERSTOTAL
  
  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++CONFIGURAÇÃO DE ORDEM MAGIC 1++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
      if(OrdersTotal()==1)
      {
      int cnt, total=OrdersTotal();
      for(cnt=0;cnt<total;cnt++)
      {
         if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber1)
         {
           
                     
            if(OrderType()==OP_BUY)
            {  //DEFINIÇÃO DE STOP
               if(Ask+STOP1*MyPoint < OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,Lots2,Ask,Slippage,0,0,NULL,MagicNumber2,0,Blue);
            }//FIM OP_BUY
            
            
            if(OrderType()==OP_SELL)
            {  //DEFINIÇÃO DE STOP
               if(Bid-STOP1*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,Lots2,Bid,Slippage,0,0,NULL,MagicNumber2,0,Red);
            }//FIM OP_SELL      
            
            
         }//FIM ORDERMAGIC
      }//FIM CONTADOR      
      }      
               
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++CONFIGURAÇÃO DE ORDEM MAGIC 2++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
            
            if(OrdersTotal()==2)
            {
            int cntt, totalt=OrdersTotal();
            for(cntt=0;cntt<totalt;cntt++)
            {
               if(OrderSelect(cntt,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
               {
                  if(OrderType()==OP_SELL)
                  {  //DEFINIÇÃO DE TAKE
                     if(Bid+TAKE2*MyPoint<OrderOpenPrice()) bool TAKESHELL2=true;
                     
                     //DEFINIÇÃO DE STOP E ORDERSEND MAGIC3
                     if(Bid-STOP2*MyPoint>OrderOpenPrice() )
                     {
                      
                      ticket = OrderSend(Symbol(),OP_SELL,Lots3,Bid,Slippage,0,Bid-15*MyPoint,NULL,MagicNumber3,0,Red);
                      }
                     
                  }
                  
                  if(OrderType()==OP_BUY)
                  {  //DEFINIÇÃO DE TAKE
                     if(Ask-TAKE2*MyPoint>OrderOpenPrice()) bool TAKEBUY2=true; 
                     
                     if(Ask+STOP2*MyPoint<OrderOpenPrice() )
                     {
                         
                         ticket =  OrderSend(Symbol(),OP_BUY,Lots3,Ask,Slippage,0,Ask+15*MyPoint,NULL,MagicNumber3,0,Blue);
                         }
                     
                  }
               
               }//FIM MAGIC2
             }//FIM CONTADOR
  
  }
  
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++CONFIGURAÇÃO MAGIC3++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
            
            int f, totalf=OrdersTotal();
            for(f=0;f<totalf;f++)
            {
               if(OrderSelect(f,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber3)
               {
                  if(OrderType()==OP_SELL)
                  {
                     if(Bid+TAKE3*MyPoint<OrderOpenPrice()) bool TAKESHELL3=true;
                     if(Bid-STOP3*MyPoint>OrderOpenPrice() ) bool STOPSHELL3=true;

                  }


                  if(OrderType()==OP_BUY)
                  {
                      if(Ask-TAKE3*MyPoint>OrderOpenPrice()) bool TAKEBUY3=true; 
                      if(Ask+STOP3*MyPoint<OrderOpenPrice() )bool STOPBUY3=true;
   
                  }    
                  
               }
            } 

 //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++FECHAMENTO DE TODAS AS ORDENS++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
            int v, totalv=OrdersTotal();
            for(v=0;v<totalv;v++)
            {
               if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES))
               {
                 if( STOPSHELL3==true || STOPBUY3==true || TAKEBUY3==true || TAKESHELL3==true || TAKESHELL2==true || TAKEBUY2==true ) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                } 
           
            }//FIM CONTADOR  
  
  
   //POR ALGUM MOTIVO A ORDEM2 SO FECHA ABRINDO OUTRO CONTADOR.                
            int vx, totalvx=OrdersTotal();
            for(vx=0;vx<totalvx;vx++)
            {
               if(OrderSelect(vx,SELECT_BY_POS,MODE_TRADES))
               {
                  if(OrderMagicNumber()==MagicNumber2)
                  {
                        if( STOPSHELL3==true || STOPBUY3==true ||  TAKEBUY3==true || TAKESHELL3==true || TAKESHELL2==true || TAKEBUY2==true ) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                        
                  }
                  }
                  }      
  
  
  
  }//FIM ONTICK
