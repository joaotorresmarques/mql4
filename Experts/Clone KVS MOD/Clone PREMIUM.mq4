/*========DESCRIÇÃO Clone PREMIUM======
1. BUY e SHELL lançados
2. se BUY der take, prevendo pullback, MAGIC2 shell
3. se MAGIC2 der STOP então MAGIC3 de shell tambem
4. Se MAGIC3 der STOP então MAGIC4 de BUY com LOT MUITO GRANDE pra recuperar prejuizo.
5. Se MAGIC4 for lançado então ele  é obrigado a dar take!
6. MAGIC4 aberto junto com todas as ordens. Todas as ordens são encerradas quando MAGIC4 der take(PERIGOSO).


=======================*/


/*=======================================================ANOTAÇÕES========================================================
FINALIZADO. Data para testar em conta demo de 100USD: 11/04/16.


Gerenciamento de risco OK! Os lots que foram definidos será mantido! A margem esta segura.

Verificar depois EA SmartAssTrade_update2. Calcula quanto tem de dinheiro e define o LOT.

========================================================================================================================*/
input int MagicNumber1=1001; 
input int MagicNumber2=1002;
input int MagicNumber3=1003;
input int MagicNumber4=1004;

input double Lots1=0.01;
input double Lots2=0.02;
input double Lots3=0.08;
input double Lots4=1.0; //era 0,40.   

input int Slippage = 6;

input int oneTP = 38;  
input int twooSP = 20;
input int twooTP = 20;
input int threeSP = 10;
input int threeTP = 10;
input int fourTP = 7;
input int fourSP = 20;

bool existemagic4;
int ticket;


int OnInit(){return(INIT_SUCCEEDED);}
void OnDeinit(const int reason){}


void OnTick()
  {
//---
              double BB20Pupper = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_UPPER,0);
              double BB20main   = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_MAIN,0);
              double BB20Plower = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_LOWER,0);
              
              /*double BB55Pupper = iBands(NULL,0,55,2,0,PRICE_CLOSE,MODE_UPPER,0);
              double BB55main   = iBands(NULL,0,55,2,0,PRICE_CLOSE,MODE_MAIN,0);
              double BB55Plower = iBands(NULL,0,55,2,0,PRICE_CLOSE,MODE_LOWER,0);
               */

              //=================POINT=====================================
               double MyPoint=Point;                                      
               if(Digits==3 || Digits==5) MyPoint=Point*10;               
             //============================================================
                    
                
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA MAGIC1++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
      if((High[2] > BB20Pupper && High[1] < BB20Pupper) || (Low[2] < BB20Plower && Low[1] > BB20Plower))
      {
      
         if(OrdersTotal()==0)
         { 
            ticket   =      OrderSend(Symbol(),OP_BUY,Lots1,Ask,0,0,0,NULL,MagicNumber1,0,Blue);      
            ticket   =      OrderSend(Symbol(),OP_SELL,Lots1,Bid,0,0,0,NULL,MagicNumber1,0,Red);
         }//FIM OrdersTotal
      }
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++STOP E TAKE MAGIC1++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

            int cntt, totalt=OrdersTotal();
            for(cntt=0;cntt<totalt;cntt++)
            {
               if(OrderSelect(cntt,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber1 && existemagic4==false)
               {
                  if(OrderType()==OP_SELL)
                  {
                     if(Bid+oneTP*MyPoint<OrderOpenPrice()) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                  }
                  
                  if(OrderType()==OP_BUY)
                  {
                     if(Ask-oneTP*MyPoint>OrderOpenPrice()) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);  
                  }
               
               }
             }
      
      
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA MAGIC2++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

         if(OrdersTotal()==1)
         {
            int cnt, total=OrdersTotal();
            for(cnt=0;cnt<total;cnt++)
            {
               if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber1)
               {
      
                  if(OrderType()==OP_SELL)
                  {  
                     ticket = OrderSend(Symbol(),OP_SELL,Lots2,Bid,Slippage,0,0,NULL,MagicNumber2,0,Red);      
                  }//FIM OP_SELL   
         
                  if(OrderType()==OP_BUY)
                  {
                     ticket = OrderSend(Symbol(),OP_BUY,Lots2,Ask,Slippage,0,0,NULL,MagicNumber2,0,Blue);
                  }//FIM OP_BUY
                  
               }//FIM OrderMagicNumber        
        
             }//Fim Contador
          }//FIM IF 
          
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++STOP E TAKE MAGIC2++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++     
      
      int j, totalj=OrdersTotal();
      for(j=0;j<totalj;j++)
      {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
         {
            if(OrderType()==OP_SELL)
            {     
              if(Bid+twooTP*MyPoint<OrderOpenPrice())  bool TAKE2shell = true;
              if(Bid-twooSP*MyPoint>OrderOpenPrice())  bool STOP2shell = true;
              
            }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
               if(Ask-twooTP*MyPoint>OrderOpenPrice()) bool TAKE2buy = true; 
               if(Ask+twooSP*MyPoint<OrderOpenPrice()) bool STOP2buy = true;
                
            }//FIM OP_BUY
               
         }//FIM MAGIC
      }//FIM CONTADOR            
  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA MAGIC3++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++       
         
         if(OrdersTotal()==2 && existemagic4==false)
         {
            int d, totald=OrdersTotal();
            for(d=0;d<totald;d++)
            {
               if(OrderSelect(d,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
               {

                  if(OrderType()==OP_SELL)
                  {  
                     if(STOP2shell==true) ticket = OrderSend(Symbol(),OP_SELL,Lots3,Bid,Slippage,0,0,NULL,MagicNumber3,0,Red);
                   
                  }
               
                  if(OrderType()==OP_BUY)
                  {
                     if(STOP2buy==true) ticket = OrderSend(Symbol(),OP_BUY,Lots3,Ask,Slippage,0,0,NULL,MagicNumber3,0,Blue);
                  }    
                  
                  
                 
               }//FIM MAGIC
            }//FIM CONTADOR
        }//FIM ORDERS.
               
                  
                    
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++STOP E TAKE MAGIC3++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++     
      
      int k, totalk=OrdersTotal();
      for(k=0;k<totalk;k++)
      {
         if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber3)
         {
            if(OrderType()==OP_SELL)
            { 
               if(Bid+threeTP*MyPoint<OrderOpenPrice()) bool TAKE3shell = true;
               
               if(Bid-threeSP*MyPoint>OrderOpenPrice()) bool STOP3shell = true;
                
             }//FIM OP_SELL   
             
            if(OrderType()==OP_BUY)
            {
               if(Ask-threeTP*MyPoint>OrderOpenPrice()) bool TAKE3buy = true;
               if(Ask+threeSP*MyPoint<OrderOpenPrice()) bool STOP3buy = true;
               
            }//FIM OP_BUY    
         
         }//FIM MAGIC
     
     }//FIM CONTADOR  
          
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++Abertura MAGIC4++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++             
    
     if(OrdersTotal()==3  )
     {
      int h, totalh=OrdersTotal();
      for(h=0;h<totalh;h++)
      {
         if(OrderSelect(h,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber3)
         {
            if(OrderType()==OP_SELL)
            {
              if(STOP3shell ==true) ticket =  OrderSend(Symbol(),OP_BUY,Lots4,Ask,Slippage,0,0,NULL,MagicNumber4,0,Blue);   
            }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
              if(STOP3buy==true) ticket = OrderSend(Symbol(),OP_SELL,Lots4,Bid,Slippage,0,0,NULL,MagicNumber4,0,Red);
            }//FIM OP_BUY
            
         }//FIM MAGIC
         }//FIM CONTADOR             
          }//FIM ORDERSTOTAL
         
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++STOP E TAKE MAGIC4++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++     
      
      int b, totalb=OrdersTotal();
      for(b=0;b<totalb;b++)
      {
         if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber4)
         {
            if((OrderMagicNumber()==MagicNumber4)==true)
            {  
               existemagic4=true;
               }
               
            
            if(OrderType()==OP_BUY)
            {  if(Ask+fourSP*MyPoint<OrderOpenPrice()) bool STOP4buy = true; //STOP NO MAGIC4
               if(Ask-fourTP*MyPoint>OrderOpenPrice())  bool TAKE4buy = true;
               
            }//FIM OP_BUY
           
           if(OrderType()==OP_SELL)
           {
             if(Bid-fourSP*MyPoint>OrderOpenPrice()) bool STOP4shell = true;//STOP NO MAGIC4
             if(Bid+fourTP*MyPoint<OrderOpenPrice())    bool TAKE4shell = true;
           }//FIM OP_SELL 
           
         }//FIM MAGIC
         
         else if((OrderMagicNumber()==MagicNumber4)==false)
         {
            existemagic4=false;
            
            }
            
      }//FIM CONTADOR.         
                        
               
                   
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++FECHAMENTO DE TODAS AS ORDENS++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++                     
                          
     int v, totalv=OrdersTotal();
            for(v=0;v<totalv;v++)
            {
               if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES))
               {
                 if( TAKE4buy==true || TAKE4shell==true || STOP4buy==true || STOP4shell==true) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                } 
           
            }//FIM CONTADOR                
                   
   
  
  int vt, totalvt=OrdersTotal();
            for(vt=0;vt<totalvt;vt++)
            {
               if(OrderSelect(vt,SELECT_BY_POS,MODE_TRADES))
               {
                  if(existemagic4==false)
                  {
                   if( TAKE2buy==true || TAKE2shell==true || 
                       TAKE3shell==true || TAKE3buy==true) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                } 
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
                     if(existemagic4==false)
                     {
                  
                     if(TAKE2buy==true || TAKE2shell==true || 
                        TAKE3shell==true || TAKE3buy==true || 
                        TAKE4buy==true || TAKE4shell==true) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                  }}}
           
            }//FIM CONTADOR         
       
       
    
        
   }//FIM OnTick()
//+------------------------------------------------------------------+

  