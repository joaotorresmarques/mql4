
/*=======================================================ANOTAÇÕES========================================================
  //ea murrey_ea   
  

Fazer uma exclusao das 2 ordens se ficarem mais de 2minutos em aberto
========================================================================================================================*/

static input string Option1 = "--------Options Basic";
extern int MagicNumber = 9090909; 
extern int StopLoss = 10;
extern int Tralling =10;
extern int stepTralling = 5;
extern double Lots = 0.01;
extern int DistancePips = 5;

static input string Week = "Dias na semana para operar";
extern bool SegundaFeira = true; 
extern bool TercaFeira = true; 
extern bool QuartaFeira = true; 
extern bool QuintaFeira = true;
extern bool SextaFeira = true; 


//Noticias de Segunda
static input string S1NOTICIAS1 = "Segunda Feira NEWS1";
extern bool S1News1 = false;
extern int S1hour1 = 0;
extern int S1minu1 = 0;

static input string S1NOTICIAS2 = "Segunda Feira NEWS2";
extern bool S1News2 = false;
extern int S1hour2 = 0;
extern int S1minu2 = 0;

static input string S1NOTICIAS3 = "Segunda Feira NEWS3";
extern bool S1News3 = false;
extern int S1hour3 = 0;
extern int S1minu3 = 0;

static input string S1NOTICIAS4 = "Segunda Feira NEWS4";
extern bool S1News4 = false;
extern int S1hour4 = 0;
extern int S1minu4 = 0;

static input string S1NOTICIAS5 = "Segunda Feira NEWS5";
extern bool S1News5 = false;
extern int S1hour5 = 0;
extern int S1minu5 = 0;

static input string S1NOTICIAS6 = "Segunda Feira NEWS6";
extern bool S1News6 = false;
extern int S1hour6 = 0;
extern int S1minu6 = 0;

static input string S1NOTICIAS7 = "Segunda Feira NEWS7";
extern bool S1News7 = false;
extern int S1hour7 = 0;
extern int S1minu7 = 0;


//Noticias de Terça
static input string TNOTICIAS1 = "Terça Feira NEWS1";
extern bool TNews1 = false;
extern int Thour1 = 0;
extern int Tminu1 = 0;

static input string TNOTICIAS2 = "Terça Feira NEWS2";
extern bool TNews2 = false;
extern int Thour2 = 0;
extern int Tminu2 = 0;

static input string TNOTICIAS3 = "Terça Feira NEWS3";
extern bool TNews3 = false;
extern int Thour3 = 0;
extern int Tminu3 = 0;

static input string TNOTICIAS4 = "Terça Feira NEWS4";
extern bool TNews4 = false;
extern int Thour4 = 0;
extern int Tminu4 = 0;

static input string TNOTICIAS5 = "Terça Feira NEWS5";
extern bool TNews5 = false;
extern int Thour5 = 0;
extern int Tminu5 = 0;

static input string TNOTICIAS6 = "Terça Feira NEWS6";
extern bool TNews6 = false;
extern int Thour6 = 0;
extern int Tminu6 = 0;

static input string TNOTICIAS7 = "Terça Feira NEWS7";
extern bool TNews7 = false;
extern int Thour7 = 0;
extern int Tminu7 = 0;

//Noticias de Quarta
static input string Q1NOTICIAS1 = "Quarta Feira NEWS1";
extern bool Q1News1 = false;
extern int Q1hour1 = 0;
extern int Q1minu1 = 0;

static input string Q1NOTICIAS2 = "Quarta Feira NEWS2";
extern bool Q1News2 = false;
extern int Q1hour2 = 0;
extern int Q1minu2 = 0;

static input string Q1NOTICIAS3 = "Quarta Feira NEWS3";
extern bool Q1News3 = false;
extern int Q1hour3 = 0;
extern int Q1minu3 = 0;

static input string Q1NOTICIAS4 = "Quarta Feira NEWS4";
extern bool Q1News4 = false;
extern int Q1hour4 = 0;
extern int Q1minu4 = 0;

static input string Q1NOTICIAS5 = "Quarta Feira NEWS5";
extern bool Q1News5 = false;
extern int Q1hour5 = 0;
extern int Q1minu5 = 0;

static input string Q1NOTICIAS6 = "Quarta Feira NEWS6";
extern bool Q1News6 = false;
extern int Q1hour6 = 0;
extern int Q1minu6 = 0;

static input string Q1NOTICIAS7 = "Quarta Feira NEWS7";
extern bool Q1News7 = false;
extern int Q1hour7 = 0;
extern int Q1minu7 = 0;

//Noticias de Quinta
static input string Q2NOTICIAS1 = "Quinta Feira NEWS1";
extern bool Q2News1 = false;
extern int Q2hour1 = 0;
extern int Q2minu1 = 0;

static input string Q2NOTICIAS2 = "Quinta Feira NEWS2";
extern bool Q2News2 = false;
extern int Q2hour2 = 0;
extern int Q2minu2 = 0;

static input string Q2NOTICIAS3 = "Quinta Feira NEWS3";
extern bool Q2News3 = false;
extern int Q2hour3 = 0;
extern int Q2minu3 = 0;

static input string Q2NOTICIAS4 = "Quinta Feira NEWS4";
extern bool Q2News4 = false;
extern int Q2hour4 = 0;
extern int Q2minu4 = 0;

static input string Q2NOTICIAS5 = "Quinta Feira NEWS5";
extern bool Q2News5 = false;
extern int Q2hour5 = 0;
extern int Q2minu5 = 0;

static input string Q2NOTICIAS6 = "Quinta Feira NEWS6";
extern bool Q2News6 = false;
extern int Q2hour6 = 0;
extern int Q2minu6 = 0;

static input string Q2NOTICIAS7 = "Quinta Feira NEWS7";
extern bool Q2News7 = false;
extern int Q2hour7 = 0;
extern int Q2minu7 = 0;

//Noticias de Sexta
static input string S2NOTICIAS1 = "Sexta Feira NEWS1";
extern bool S2News1 = false;
extern int S2hour1 = 0;
extern int S2minu1 = 0;

static input string S2NOTICIAS2 = "Sexta Feira NEWS2";
extern bool S2News2 = false;
extern int S2hour2 = 0;
extern int S2minu2 = 0;

static input string S2NOTICIAS3 = "Sexta Feira NEWS3";
extern bool S2News3 = false;
extern int S2hour3 = 0;
extern int S2minu3 = 0;

static input string S2NOTICIAS4 = "Sexta Feira NEWS4";
extern bool S2News4 = false;
extern int S2hour4 = 0;
extern int S2minu4 = 0;

static input string S2NOTICIAS5 = "Sexta Feira NEWS5";
extern bool S2News5 = false;
extern int S2hour5 = 0;
extern int S2minu5 = 0;

static input string S2NOTICIAS6 = "Sexta Feira NEWS6";
extern bool S2News6 = false;
extern int S2hour6 = 0;
extern int S2minu6 = 0;

static input string S2NOTICIAS7 = "Sexta Feira NEWS7";
extern bool S2News7 = false;
extern int S2hour7 = 0;
extern int S2minu7 = 0;
int ab ;


string Robo = "Noticias 1.0";
int ticket;
bool Order2,countsellFINISH,countbuyFINISH;



int OnInit(){return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
   

                           

         static int closedOrders=0;
         if(OrdersHistoryTotal()!=closedOrders)
         {
            closedOrders=OrdersHistoryTotal();
            int hstTotal = OrdersHistoryTotal(); 
        
            if(OrderSelect(hstTotal-1,SELECT_BY_POS,MODE_HISTORY))
            {
               if(OrderMagicNumber()==MagicNumber)
               {  
                  if(OrderType()==OP_SELL)
                  {
                    ab = OrderCloseTime()+20*60;
                    
                  }
                  
                  if(OrderType()==OP_BUY)
                  {
                    ab = OrderCloseTime()+20*60;
                    
                  }
              }
           }
       }
                  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++                   
  
   if(OrdersTotal()==0)
   {  if (Time[0] > ab){
      if (ConfirmTrade()==true)
      {
          ticket = OrderSend(Symbol(),OP_BUYSTOP,Lots,Ask+DistancePips*MyPoint,0,0,0,Robo,MagicNumber,0,Blue);
          ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,Bid-DistancePips*MyPoint,0,0,0,Robo,MagicNumber,0,Red);
     
      }
   }
}
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++Tralling Stop++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
 
 for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
    {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber  )
         {  
               if(OrderType()==OP_BUY)
               {
                
                  double stnewpricebuy = OrderOpenPrice();
                  double SL = OrderStopLoss();
              
                  if(SL==0 && OrderClosePrice()-Tralling*MyPoint>stnewpricebuy) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(stepTralling)*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && (Bid>OrderStopLoss()+Tralling*MyPoint))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()+(stepTralling)*MyPoint,0,0,clrLightGreen);
               
               
               }//FIM OP_BUY  
   
                if(OrderType()==OP_SELL)
                {
                  
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && OrderClosePrice()+10*MyPoint<stnewpricesell) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(Tralling-4)*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && (Ask<OrderStopLoss()-5*MyPoint))  ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()-(stepTralling-4)*MyPoint,0,0,clrLightGreen);
               }//FIM OP_SELL
              
              
              
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR   
 

 
//=========================CONTADOR DE ORDENS ABERTAS  
  
   bool countsellstop,countbuystop,countsell,countbuy;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) 
   {
      int a = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);

         if (OrderType() == OP_SELLSTOP) countsellstop=true; 
         if (OrderType() == OP_BUYSTOP) countbuystop=true; 
         if (OrderType() == OP_SELL) countsell=true; 
         if (OrderType() == OP_BUY) countbuy=true;   
   }//FIM CONTADOR

 
////SE 2 ORDENS ABERTA quando ativa uma a outra fecha.

   if(OrdersTotal()==0){ Order2=false;countbuyFINISH=false;countsellFINISH=false; }
      
   if(countbuystop==true && countsellstop==true) Order2=true;
                
   if(Order2==true)
   {
      if(countbuystop==true && countsellstop==false) countbuyFINISH  = true;    
      if(countbuystop==false && countsellstop==true) countsellFINISH = true;
   }
   
//EXCLUSAO.   
   for (int trade733=OrdersTotal()-1; trade733>=0; trade733--) 
   {
      if(OrderSelect(trade733,SELECT_BY_POS, MODE_TRADES)) 
      {  
         if(OrderType()==OP_BUYSTOP)
         {   
             if(countbuyFINISH==true) ticket = OrderDelete(OrderTicket(),Green);  
         }
            
      }//FIM BUYSTOP
            
        if(OrderType()==OP_SELLSTOP)
        {  
           if(countsellFINISH==true) ticket = OrderDelete(OrderTicket(),Green); 
        }//FIM OP_SELLSTOP       
         
         
     
  }//FIM CONTADOR 
 
 
 
 
 
 
 
 
 
 
 
  
  
  }//FIM ONTICK
 


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++GATILHO DE ENTRADA++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 



bool ConfirmTrade()
{
   
   if(TimeDayOfWeek(TimeLocal())== 1 && SegundaFeira==true)
   { 
      if(S1News1==true)
      {
         if(Hour()==S1hour1 && Minute()==S1minu1) return true;
      }
      
         if(S1News2==true)
         {
            if(Hour()==S1hour2 && Minute()==S1minu2) return true;
         }      
      
            if(S1News3==true)
            {
               if(Hour()==S1hour3 && Minute()==S1minu3) return true;
            }
      
               if(S1News4==true)
               {
                  if(Hour()==S1hour4 && Minute()==S1minu4) return true;
               }
      
                  if(S1News5==true)
                  {
                     if(Hour()==S1hour5 && Minute()==S1minu5) return true;
                  }  
      
                     if(S1News6==true)
                     {
                        if(Hour()==S1hour6 && Minute()==S1minu6) return true;
                     }
      
                        if(S1News7==true)
                        {
                           if(Hour()==S1hour7 && Minute()==S1minu7) return true;
                        }
      
   }//FIM SEGUNDAFEIRA                  
   
   if(TimeDayOfWeek(TimeLocal())== 2 && TercaFeira==true)
   { 
      if(TNews1==true)
      {
         if(Hour()==Thour1 && Minute()==Tminu1) return true;
      }
      
         if(TNews2==true)
         {
            if(Hour()==Thour2 && Minute()==Tminu2) return true;
         }      
      
            if(TNews3==true)
            {
               if(Hour()==Thour3 && Minute()==Tminu3) return true;
            }
      
               if(TNews4==true)
               {
                  if(Hour()==Thour4 && Minute()==Tminu4) return true;
               }
      
                  if(TNews5==true)
                  {
                     if(Hour()==Thour5 && Minute()==Tminu5) return true;
                  }  
      
                     if(TNews6==true)
                     {
                        if(Hour()==Thour6 && Minute()==Tminu6) return true;
                     }
      
                        if(TNews7==true)
                        {
                           if(Hour()==Thour7 && Minute()==Tminu7) return true;
                        }
      
   }//FIM TERCAFEIRA
   
   if(TimeDayOfWeek(TimeLocal())== 3 && QuartaFeira==true)
   { 
      if(Q1News1==true)
      {
         if(Hour()==Q1hour1 && Minute()==Q1minu1) return true;
      }
      
         if(Q1News2==true)
         {
            if(Hour()==Q1hour2 && Minute()==Q1minu2) return true;
         }      
      
            if(Q1News3==true)
            {
               if(Hour()==Q1hour3 && Minute()==Q1minu3) return true;
            }
      
               if(Q1News4==true)
               {
                  if(Hour()==Q1hour4 && Minute()==Q1minu4) return true;
               }
      
                  if(Q1News5==true)
                  {
                     if(Hour()==Q1hour5 && Minute()==Q1minu5) return true;
                  }  
      
                     if(Q1News6==true)
                     {
                        if(Hour()==Q1hour6 && Minute()==Q1minu6) return true;
                     }
      
                        if(Q1News7==true)
                        {
                           if(Hour()==Q1hour7 && Minute()==Q1minu7) return true;
                        }
      
   }//FIM QUARTAFEIRA    
   
   if(TimeDayOfWeek(TimeLocal())== 4 && QuintaFeira==true)
   { 
      if(Q2News1==true)
      {
         if(Hour()==Q2hour1 && Minute()==Q2minu1) return true;
      }
      
         if(Q2News2==true)
         {
            if(Hour()==Q2hour2 && Minute()==Q2minu2) return true;
         }      
      
            if(Q2News3==true)
            {
               if(Hour()==Q2hour3 && Minute()==Q2minu3) return true;
            }
      
               if(Q2News4==true)
               {
                  if(Hour()==Q2hour4 && Minute()==Q2minu4) return true;
               }
      
                  if(Q2News5==true)
                  {
                     if(Hour()==Q2hour5 && Minute()==Q2minu5) return true;
                  }  
      
                     if(Q2News6==true)
                     {
                        if(Hour()==Q2hour6 && Minute()==Q2minu6) return true;
                     }
      
                        if(Q2News7==true)
                        {
                           if(Hour()==Q2hour7 && Minute()==Q2minu7) return true;
                        }
      
   }//FIM QUINTAFEIRA     
   
   if(TimeDayOfWeek(TimeLocal())== 5 && SextaFeira==true)
   { 
      if(S2News1==true)
      {
         if(Hour()==S2hour1 && Minute()==S2minu1) return true;
      }
      
         if(S2News2==true)
         {
            if(Hour()==S2hour2 && Minute()==S2minu2) return true;
         }      
      
            if(S2News3==true)
            {
               if(Hour()==S2hour3 && Minute()==S2minu3) return true;
            }
      
               if(S2News4==true)
               {
                  if(Hour()==S2hour4 && Minute()==S2minu4) return true;
               }
      
                  if(S2News5==true)
                  {
                     if(Hour()==S2hour5 && Minute()==S2minu5) return true;
                  }  
      
                     if(S2News6==true)
                     {
                        if(Hour()==S2hour6 && Minute()==S2minu6) return true;
                     }
      
                        if(S2News7==true)
                        {
                           if(Hour()==S2hour7 && Minute()==S2minu7) return true;
                        }
      
   }//FIM SEXTAFEIRA                                                              

return false;
}//FIM CONFIRMTRADE()