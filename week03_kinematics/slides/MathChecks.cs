using System;
public static class Week3MathChecks {
 public static int Checks;public static double WorstError;
 static double[] Fk(double a,double b){return new[]{.6*Math.Cos(a)+.4*Math.Cos(a+b),.6*Math.Sin(a)+.4*Math.Sin(a+b)};}
 static double[] Ik(double x,double y,int sign){double r=Math.Sqrt(x*x+y*y);if(r<.2-1e-12||r>1+1e-12)throw new ArgumentException("unreachable");double c=(x*x+y*y-.36-.16)/.48;double b=sign*Math.Acos(Math.Max(-1,Math.Min(1,c)));double a=Math.Atan2(y,x)-Math.Atan2(.4*Math.Sin(b),.6+.4*Math.Cos(b));a=Math.Atan2(Math.Sin(a),Math.Cos(a));return new[]{a,b};}
 static void Near(double[] a,double[] b,string label,double tol=1e-9){double e=0;for(int i=0;i<a.Length;i++)e=Math.Max(e,Math.Abs(a[i]-b[i]));if(double.IsNaN(e)||e>tol)throw new Exception(label+": "+e);Checks++;WorstError=Math.Max(WorstError,e);}
 static double[,] I(){return new double[,]{{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1}};}
 static double[,] R(double q){var m=I();m[0,0]=Math.Cos(q);m[0,1]=-Math.Sin(q);m[1,0]=Math.Sin(q);m[1,1]=Math.Cos(q);return m;}
 static double[,] T(double x){var m=I();m[0,3]=x;return m;}
 static double[,] Mul(double[,] a,double[,] b){var m=new double[4,4];for(int i=0;i<4;i++)for(int j=0;j<4;j++)for(int k=0;k<4;k++)m[i,j]+=a[i,k]*b[k,j];return m;}
 static double[] TransformFk(double a,double b){var m=Mul(Mul(Mul(R(a),T(.6)),R(b)),T(.4));Near(new[]{m[0,0],m[1,0]},new[]{Math.Cos(a+b),Math.Sin(a+b)},"tool orientation");return new[]{m[0,3],m[1,3]};}
 static double[] Partial(double a,double b,int joint){double h=1e-6;var plus=Fk(a+(joint==0?h:0),b+(joint==1?h:0));var minus=Fk(a-(joint==0?h:0),b-(joint==1?h:0));return new[]{(plus[0]-minus[0])/(2*h),(plus[1]-minus[1])/(2*h)};}
 public static object Run(){Checks=0;WorstError=0;Near(Fk(0,0),new[]{1.0,0},"zero");Near(Fk(0,Math.PI/2),new[]{.6,.4},"worked FK");var pos=Ik(.6,.4,1);var neg=Ik(.6,.4,-1);Near(pos,new[]{0.0,Math.PI/2},"positive branch");Near(neg,new[]{1.176005207095135,-Math.PI/2},"negative branch");Near(new[]{pos[0]+pos[1],neg[0]+neg[1]},new[]{Math.PI/2,-.394791119699761},"tool orientations");
 foreach(double a in new[]{-2.7,-1.0,0,.8,2.7})foreach(double b in new[]{-2.5,-.6,.6,2.5}){var point=Fk(a,b);Near(point,TransformFk(a,b),"independent transform FK");foreach(int sign in new[]{1,-1}){var q=Ik(point[0],point[1],sign);Near(Fk(q[0],q[1]),point,"IK round trip");if(Math.Abs(q[0])>Math.PI+1e-10||Math.Abs(q[1])>Math.PI+1e-10)throw new Exception("angle limits");Checks++;}var da=Partial(a,b,0);var db=Partial(a,b,1);Near(new[]{da[0]*db[1]-db[0]*da[1]},new[]{.24*Math.Sin(b)},"finite-difference Jacobian",1e-6);}
 foreach(double radius in new[]{.2,1.0})foreach(double bearing in new[]{0.0,1.2,Math.PI})foreach(int sign in new[]{1,-1}){var q=Ik(radius*Math.Cos(bearing),radius*Math.Sin(bearing),sign);Near(Fk(q[0],q[1]),new[]{radius*Math.Cos(bearing),radius*Math.Sin(bearing)},"singular boundary",1e-8);}
 foreach(double b in new[]{0.0,Math.PI,-Math.PI}){var da=Partial(.4,b,0);var db=Partial(.4,b,1);Near(new[]{da[0]*db[1]-db[0]*da[1]},new[]{0.0},"singular determinant",1e-6);}
 foreach(double[] p in new[]{new[]{1.2,0.0},new[]{0.0,0.0},new[]{.1,0.0},new[]{1.0001,0.0}}){bool rejected=false;try{Ik(p[0],p[1],1);}catch(ArgumentException){rejected=true;}if(!rejected)throw new Exception("unreachable accepted");Checks++;}
 Near(Fk(0,1.561),new[]{.603918468045,.399980806549},"representative measured FK",2e-6);
 return new{status="PASS",checks=Checks,worstAbsoluteError=WorstError,positiveBranch=pos,negativeBranch=neg,position=new[]{.6,.4},existingPythonUnitTests="Not executed here; no local Python/ROS runtime. These are independent slide-math checks."};}
}
