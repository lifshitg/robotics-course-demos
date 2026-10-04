using System;
using System.Collections.Generic;
using System.Linq;

// Independent numerical checks and editable-slide illustrations; not demo code.
public static class Week4Geometry {
 public static double[] Start = {-.7,.6}, Goal={.7,-.6};
 public static double Distance(double[] a,double[] b) {return Math.Sqrt(a.Zip(b,(x,y)=>(x-y)*(x-y)).Sum());}
 public static double[][] FK(double[] q) {return new[]{new[]{0.0,0.0},new[]{.6*Math.Cos(q[0]),.6*Math.Sin(q[0])},new[]{.6*Math.Cos(q[0])+.4*Math.Cos(q[0]+q[1]),.6*Math.Sin(q[0])+.4*Math.Sin(q[0]+q[1])}};}
 public static double Segment(double[] p,double[] a,double[] b) {double dx=b[0]-a[0],dy=b[1]-a[1],d=dx*dx+dy*dy; double u=d==0?0:Math.Max(0,Math.Min(1,((p[0]-a[0])*dx+(p[1]-a[1])*dy)/d));return Distance(p,new[]{a[0]+u*dx,a[1]+u*dy});}
 public static double Clearance(double[] q) {var p=FK(q);return Math.Min(Segment(new[]{.8,0},p[0],p[1]),Segment(new[]{.8,0},p[1],p[2]))-.12-.03;}
 public static bool Free(double[] q) {return q.Length==2 && q.All(x=>!double.IsNaN(x)&&!double.IsInfinity(x)&&Math.Abs(x)<=Math.PI)&&Clearance(q)>.01;}
 public static double[][] Interpolate(double[] a,double[] b,double step=.01) {int n=Math.Max(1,(int)Math.Ceiling(a.Zip(b,(x,y)=>Math.Abs(x-y)).Max()/step));return Enumerable.Range(0,n+1).Select(i=>new[]{a[0]+(b[0]-a[0])*i/n,a[1]+(b[1]-a[1])*i/n}).ToArray();}
 public static bool Edge(double[] a,double[] b,double step=.01) {return Interpolate(a,b,step).All(Free);}
 public static double[][] Points = new[]{new[]{-1.8,1.9},new[]{-1.05,1.6},new[]{-.5,1.9},new[]{-.05,2.0},new[]{.2,2.2},new[]{.4,1.2},new[]{.6,.7},new[]{.8,-.1},new[]{.9,-.7},new[]{1.5,-1.3},new[]{2.0,1.0},new[]{-1.5,-1.2},new[]{-.7,-1.7},new[]{-.2,-2.2},new[]{.45,-1.7},new[]{-2.3,.4},new[]{-1.3,.2},new[]{-.8,.6}}.Where(Free).ToArray();
 public static int[] Nearest(double[][] points,double[] q,int k,int exclude=-1) {return Enumerable.Range(0,points.Length).Where(i=>i!=exclude).OrderBy(i=>Distance(q,points[i])).ThenBy(i=>i).Take(k).ToArray();}
 public static List<int[]> Edges(double[][] points,int k=4) {var pairs=new HashSet<string>();var result=new List<int[]>();for(int i=0;i<points.Length;i++)foreach(int j in Nearest(points,points[i],k,i)){int lo=Math.Min(i,j),hi=Math.Max(i,j);if(pairs.Add(lo+":"+hi)&&Edge(points[lo],points[hi]))result.Add(new[]{lo,hi});}return result;}
 public static int[] Search(double[][] points,List<int[]> edges,int start,int goal) {var d=Enumerable.Repeat(double.PositiveInfinity,points.Length).ToArray();var prev=Enumerable.Repeat(-1,points.Length).ToArray();var visited=new bool[points.Length];d[start]=0;for(int pass=0;pass<points.Length;pass++){int u=-1;for(int i=0;i<d.Length;i++)if(!visited[i]&&(u<0||d[i]<d[u]))u=i;if(u<0||double.IsInfinity(d[u]))break;visited[u]=true;if(u==goal)break;foreach(var e in edges){int v=e[0]==u?e[1]:e[1]==u?e[0]:-1;if(v>=0&&d[u]+Distance(points[u],points[v])<d[v]){d[v]=d[u]+Distance(points[u],points[v]);prev[v]=u;}}}if(double.IsInfinity(d[goal]))return new int[0];var path=new List<int>();for(int u=goal;u!=-1;u=prev[u])path.Add(u);path.Reverse();return path.ToArray();}
 public static double[][] QueryPath() {var pts=Points.Concat(new[]{Start,Goal}).ToArray();var edges=Edges(Points);int s=Points.Length,g=s+1;foreach(int u in new[]{s,g})foreach(int v in Nearest(Points,pts[u],10))if(Edge(pts[u],pts[v]))edges.Add(new[]{u,v});if(Edge(Start,Goal))edges.Add(new[]{s,g});return Search(pts,edges,s,g).Select(i=>pts[i]).ToArray();}
 public static string[] Check() {
  var checks=new List<string>(); Action<bool,string> require=(ok,name)=>{if(!ok)throw new Exception(name);checks.Add(name);};
  require(Free(Start)&&Free(Goal),"Exact start and goal are free");require(!Free(new[]{0.0,0.0})&&!Edge(Start,Goal),"Safe endpoints but colliding midpoint/local motion");
  require(Distance(FK(new[]{0.0,Math.PI/2})[2],new[]{.6,.4})<1e-12,"FK agrees with Week 3");
  require(Math.Abs(Segment(new[]{.8,.16},new[]{0.0,0.0},new[]{1.0,0.0})-.16)<1e-12,"Padded contact distance is 0.12+0.03+0.01 m");
  require(Math.Abs(Segment(new[]{.8,0.0},FK(new[]{0.0,0.0})[0],FK(new[]{0.0,0.0})[1])-.2)<1e-12&&Segment(new[]{.8,0.0},FK(new[]{0.0,0.0})[1],FK(new[]{0.0,0.0})[2])<1e-12,"Midpoint collision is with link 2, not link 1");
  var samples=Interpolate(Start,Goal);require(samples.Length==141&&Distance(samples[0],Start)<1e-12&&Distance(samples.Last(),Goal)<1e-12,"141 local-validation samples include both endpoints");
  require(Enumerable.Range(1,samples.Length-1).All(i=>samples[i].Zip(samples[i-1],(a,b)=>Math.Abs(a-b)).Max()<=.010000000001),"Per-joint increment <=0.01 rad");
  require(!Free(new[]{Math.PI+.1,0.0})&&Interpolate(new[]{-3.0,0.0},new[]{3.0,0.0})[300][0]==0,"Limits and no boundary wrapping");
  require(Points.All(Free)&&!Points.Any(q=>Distance(q,Start)<1e-12),"Illustrative vertices are valid; actual start is unsampled");
  var path=QueryPath();require(path.Length>1&&Distance(path[0],Start)<1e-12&&Distance(path.Last(),Goal)<1e-12,"Illustrative query retains exact endpoints and finds route");
  require(Enumerable.Range(1,path.Length-1).All(i=>Edge(path[i-1],path[i],.002)),"Illustrative path passes denser 0.002-rad replay");
  require(Nearest(new[]{new[]{0.0,0.0},new[]{2.0,0.0},new[]{1.0,0.0}},new[]{0.0,0.0},10,0).SequenceEqual(new[]{2,1}),"Nearest ordering, self exclusion, fewer-than-k handling");
  require(Search(new[]{new[]{0.0,0.0},new[]{1.0,0.0}},new List<int[]>(),0,1).Length==0,"Disconnected graph returns no route");
  return checks.ToArray();
 }
}
