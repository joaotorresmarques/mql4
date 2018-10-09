/*========DESCRIÇÃO GAP 1.0====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================
              
========================================================================================================================*/

static input string Option1 = "--------Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; //BUY
extern int StopLoss = 10;
extern int TakeProfit =10;
extern int Tralling = 5;
extern double Lots = 0.01;


string Robo = "Robin Hood 1.0";
int ticket;



int OnInit(){return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
   

                           
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
         if(OrdersTotal()==0){
         if(TimeDayOfWeek(TimeLocal())== 5 && Hour()==10 && Minute()==10){
            ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots,Close[0]+5*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Blue);
            ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,Open[0]-5*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Red);
      }
    }

  }//FIM ONTICK
 
