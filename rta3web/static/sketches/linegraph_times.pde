PFont f;
float[] vals;
int[] norm;
float[] data;
int[] overrange; //postions of overranged data in the data array
int[] normOver;
boolean renorm = true, loaded = false;
int arrSize = 200;
int maxPoints = 150000;
int normlength = 0;
float step = 1.0;
int maxXPos, minXPos, length, mouse, clickX, clickY;
float minX, maxX, minY, maxY, xDiff, yDiff, minXVal, maxXVal;
String heading = "HEADING", xaxis = "x", yaxis = "y";

boolean simple = false; // change amount of functionailty, simple version for hom page.
//int mouseScroll = 0;
boolean yZoom = true, xZoom = true; //Zoom variables

void setup() {
  ////println("in setup");
  frameRate(10);
  size(1400, 500);
  smooth();
  //noLoop();

  ////println ("testing format for 12, 12.1, 12.12, 12.123, 12.1245563");
  ////println (formatFloat(132.0, 2) + " , " + formatFloat(1422.1, 2) + " , " + formatFloat(122.12, 2) + " , " + formatFloat(12342.123, 2) + " , " + formatFloat(1552.1245563, 4));

  f = createFont ("Arial", 24, true);

  // maxX = 20;
  // maxY = 20;
  // minX = 0;
  // minY = 0;
  // xDiff = maxX - minX;
  // yDiff = maxY - minY;
  // maxXPos = arrSize/2 - 1;
  // minXPos = 0;
  // length = maxXPos - minXPos + 1;

  // An array of random values
  //float[] temp = {
    //0.5, 9.0, 1.0, 11.0, 2.0, -1.0, 3.0, -2.0, 4.0, 23.0, 5.0, 29.0, 6.0, 8.0, 7.0, 9.0, 8.0, 16.0, 9.0, 14.0
  //} 
  //;
  //vals = temp;
  // vals = new float [arrSize];
  // norm = new int [arrSize];
  // for (int i = 0; i < arrSize; i++)
  // {
  //   vals[i] = random(20);
  // }
  // mehSort();
  // //println ("out setup");
}

void setSize(int x, int y)
{
  size(x, y);
}

void setSimple()
{
  simple = true;
}

void draw() {

   background(255);

  // ////println("BdrawLine");
  if(loaded)
  {
    drawLine();
    drawOverrange();
    ////println("BdrawAxes");
    drawAxes (heading, xaxis, yaxis, 10, 10);
  }
}

void testMeth(text){
  //println(text)
}

void setVals(float[] data, float maxx, float minx, float maxy, float miny, int[] over)
{
  //print("In setValues");
  vals = data;
  overrange = over;
  arrSize = vals.length;
  minXVal = minx;
  maxXVal = maxx;
  maxX = maxx - minx;
  maxY = maxy;
  minX = 0;
  minY = miny;
  xDiff = maxX - minX;
  yDiff = maxY - minY;
  maxXPos = arrSize/2 - 1;
  minXPos = 0;
  length = maxXPos - minXPos + 1;
  renorm = true;
  loaded = true;

  //println("over.length = " + over.length);
  //println("overrange.length = " + overrange.length);
}

void resetVals(float[] data)
{
  //print("In resetValues");
  vals = data;
  arrSize = vals.length;
  //maxX = maxx;
  //maxY = maxy;
  //minX = minx;
  //minY = miny;
  //xDiff = maxX - minX;
  //yDiff = maxY - minY;
  //maxXPos = arrSize/2 - 1;
  //minXPos = 0;
  //length = maxXPos - minXPos + 1;
  renorm = true;
  loaded = true;
}

void setLabels (String h, String x, String y){
  heading = h;
  xaxis = x;
  yaxis = y;
}

void keyPressed ()
{
  if (key == 's')  //Save image
    save();
  if (key == 'z') //Y zoom
    xZoom = false;
  if (key == 'x') //X Zoom
    yZoom = false;
}
void keyReleased ()
{
  if (key == 'z') //Y zoom
    xZoom = true;
  if (key == 'x') //X Zoom
    yZoom = true;
}

void mouseScrolled()
{
  if (!simple){
    //println("mouseScroll = " + mouseScroll);
    float yScale = yDiff * 0.1;
    float xScale = xDiff * 0.1;
    if (mouseScroll < 0)
    {
      if (xZoom){
        minX = minX - xScale;
        maxX = maxX + xScale;
        xDiff = maxX - minX;
      }
      if (yZoom){
        minY = minY - yScale;
        maxY = maxY + yScale;
        yDiff = maxY - minY;
      }
    }
    else
    {
      if (xZoom){
        minX = minX + xScale;
        maxX = maxX - xScale;
        xDiff = maxX - minX;
      }
      if (yZoom){
        minY = minY + yScale;
        maxY = maxY - yScale;
        yDiff = maxY - minY;
      }
    }
    renorm = true;
  }
}

void mouseDragged()
{
  if (!simple){
    int distX = clickX - mouseX;
    int distY = clickY - mouseY;
    clickX = mouseX;
    clickY = mouseY;
    //float xVal = ((distX - width * 0.1) * xDiff)/(width * 0.8) + minX;
    float xVal = xDiff * (distX/float(width));
    float yVal = yDiff * (distY/float(height));
    minX = minX + xVal;
    maxX = maxX + xVal;
    minY = minY - yVal;
    maxY = maxY - yVal;
    //xDiff = maxX - minX;
    //yDiff = maxY - minY;
    renorm = true;
    //println ("yVal = " + yVal);
  }
}

void mousePressed ()
{
  clickX = mouseX;
  clickY = mouseY;
}

/*Sort arrays according to x co-ordinates*/
void mehSort ()
{
  for (int i = 0; i < length - 1; i++)
  {
    for (int j = i; j < length; j++)
    {
      if (vals[2 * i] > vals[2 * j])
      {
        float temp = vals[2 * i];
        vals[2 * i] = vals[2 * j];
        vals[2 * j] = temp;
      }
    }
  }
}

/*Finds the point where the line defined by (x1,y1) and (x2,y2) intersects with the line y = c*/
float getIntersection (float x1, float y1, float x2, float y2, float c)
{
  ////println ("+++++++++++++++++++++++++++++++++++++++++++++");
  ////println ("x1 = " + x1 + " y1 = " + y1 + " x2 = " + x2 + " y2 = " + y2 + " c = " + c);
  float m = (y1 - y2) / (x1 - x2);
  float x = (c - y1)/m + x1;
  ////println ("x = " + x);
  return x;
}

/*Ensure that all values in an array are in the range [0,1], values which are out of range
are removed and replaced with the point where the graph intercepts the maxY or minY line.
You must ensure that all x values are within the range for the x axis before normalising.
This is the method which is most computationally heavy, call as infrequently as possible*/
void normalise ()
{
  normlength = 0;
  //println ("step = " + step);
  norm = new int[3 * maxPoints];
  data = new float[3 * maxPoints];

  // normOver = new int[overrange.length];

  /*This is too lower the amount of points that are normalised, if there is a very high number of points it
  it is not possible to actually display each point as there are not enough pixels. It is a waste to normalise
  all points and I want the experience to be a fluid as possible, so I choose maxPoints points out of all
  data points to normalise and ignore the rest. There is a problem however when graphing random data, this
  causes the whole graph shape to change wildly as you scan through the data. In this case the maxPoints
  should be set to the total number of points possible. Use with care, can cause very innacurate graphs when
  contiguous data points are not "close" to each other or data is random. Always set maxPoints as high
  as possible, but remember the higher the number of points the more computation required which may be an
  issue for usability*/
  if (length > maxPoints)
  {
    step = length/100;
  }
  int prevOut = 0;
  float xVal;
  if (vals[2*minXPos + 1] <= maxY && vals[2*minXPos + 1] >= minY)
  {
    norm[0] = int(width * 0.1 + ((vals[2*minXPos]-minX) / xDiff) * width * 0.8);
    norm[1] = int(height * 0.9 - ((vals[2*minXPos + 1]-minY) / yDiff) * height * 0.8);
    data[0] = vals[2*minXPos];
    data[1] = vals[2*minXPos + 1];
    normlength++;
    //println("In range");
  }
  else if (vals[2*minXPos + 1] > maxY) //if the first point is too high to be displayed on the Y axis
  {
    int p = minXPos;
    if (minXPos == 0)  //make sure that the following calculation does not go out of the range of the array
      p = 1;
    xVal = getIntersection(vals[2*p], vals[2*p+1], vals[2*p-2], vals[2*p-1], maxY);  //calculate the interception between the line maxY and our first 2 points
    if (xVal > minX)
      norm[0] = int(width * 0.1 + ((xVal - minX) / xDiff) * width * 0.8);
    else
    {
      norm[0] = int(width * 0.1);
      xVal = minX;
    }
    norm[1] = int(height * 0.1);
    data[0] = xVal;
    data[1] = maxY;
    normlength++;
    prevOut = 1;
    //println("Too High");
  }
  else  //if the first point is too low to be sidplayed on the y axis
  {
    int p = minXPos;
    if (minXPos == 0)
      p = 1;
    xVal = getIntersection(vals[2*p], vals[2*p+1], vals[2*p-2], vals[2*p-1], minY);
    if (xVal > minX)
      norm[0] = int(width * 0.1 + ((xVal - minX) / xDiff) * width * 0.8);
    else
    {
      norm[0] = int(width * 0.1);
      xVal = minX;
    }
    norm[1] = int(height * 0.9);
    data[0] = xVal;
    data[1] = minY;
    normlength++;
    prevOut = -1;
    //println("Too Low");
  }

  // int overrange_pos = 0;
  // int norm_over_pos = 0;
  // while (overrange_pos < overrange.length && minXPos > overrange[overrange_pos])
  // {
  //   overrange_pos++;
  // }
  // if (overrange[overrange_pos] == minXPos)
  // {
  //   normOver[norm_over_pos] == 0;
  //   norm_over_pos++;
  //   overrange_pos++;
  // }
  //boolean was_overrange = false;
  for (float i = minXPos + step; i < maxXPos; i = i + step) //All the rest of the points
  {
    // if (overrange.length > 0)
    // {
    //   if (i == overrange[overrange_pos])
    //   {
    //     normOver[norm_over_pos] = i;
    //     norm_over_pos++;
    //     overrange_pos++;
    //   }

    //}
    if (vals[2*int(i)+1] <= maxY && vals[2*int(i)+1] >= minY)
    {
      
      if (prevOut == 1)
      {
        xVal = getIntersection(vals[2*int(i)], vals[2*int(i)+1], vals[2*int(i)-2], vals[2*int(i)-1], maxY);
        norm[2 * normlength] = int(width * 0.1 + ((xVal - minX) / xDiff) * width * 0.8);
        norm[2 * normlength + 1] = int(height * 0.1);
        data[2 * normlength] = xVal;
        data[2 * normlength + 1] = maxY;
        normlength++;
        prevOut = 0;
      }
      else if (prevOut == -1)
      {
        xVal = getIntersection(vals[2*int(i)], vals[2*int(i)+1], vals[2*int(i)-2], vals[2*int(i)-1], minY);
        norm[2 * normlength] = int(width * 0.1 + ((xVal - minX) / xDiff) * width * 0.8);
        norm[2 * normlength + 1] = int(height * 0.9);
        data[2 * normlength] = xVal;
        data[2 * normlength + 1] = minY;
        normlength++;
        prevOut = 0;
      }
      norm[2 * normlength] = int(width * 0.1 + ((vals[2*int(i)] - minX) / xDiff) * width * 0.8);
      norm[2 * normlength + 1] = int(height * 0.9 - ((vals[2*int(i) + 1] - minY) / yDiff) * height * 0.8);
      data[2 * normlength] = vals[2*int(i)];
      data[2 * normlength + 1] = vals[2*int(i) + 1];
      normlength++;
      prevOut = 0;
    }
    else if (prevOut == 0)
    {
      if (vals[2*int(i)+1] > maxY)
      {
        xVal = getIntersection(vals[2*int(i)], vals[2*int(i)+1], vals[2*int(i)-2], vals[2*int(i)-1], maxY);
        norm[2 * normlength] = int(width * 0.1 + ((xVal - minX) / xDiff) * width * 0.8);
        norm[2 * normlength + 1] = int(height * 0.1);
        data[2 * normlength] = xVal;
        data[2 * normlength + 1] = maxY;
        normlength++;
        prevOut = 1;
      }
      else
      {
        xVal = getIntersection(vals[2*int(i)], vals[2*int(i)+1], vals[2*int(i)-2], vals[2*int(i)-1], minY);
        norm[2 * normlength] = int(width * 0.1 + ((xVal - minX) / xDiff) * width * 0.8);
        norm[2 * normlength + 1] = int(height * 0.9);
        data[2 * normlength] = xVal;
        data[2 * normlength + 1] = minY;
        normlength++;
        prevOut = -1;
      }
    }
    else if (vals[2*int(i)+1] > maxY && prevOut == -1)
    {
      xVal = getIntersection(vals[2*int(i)], vals[2*int(i)+1], vals[2*int(i)-2], vals[2*int(i)-1], minY);
      norm[2 * normlength] = int(width * 0.1 + ((xVal - minX) / xDiff) * width * 0.8);
      norm[2 * normlength + 1] = int(height * 0.9);
      data[2 * normlength] = xVal;
      data[2 * normlength + 1] = minY;
      normlength++;

      xVal = getIntersection(vals[2*int(i)], vals[2*int(i)+1], vals[2*int(i)-2], vals[2*int(i)-1], maxY);
      norm[2 * normlength] = int(width * 0.1 + ((xVal - minX) / xDiff) * width * 0.8);
      norm[2 * normlength + 1] = int(height * 0.1);
      data[2 * normlength] = xVal;
      data[2 * normlength + 1] = maxY;
      normlength++;

      prevOut = 1;
    }
    else if (vals[2*int(i)+1] < minY && prevOut == 1)
    {
      xVal = getIntersection(vals[2*int(i)], vals[2*int(i)+1], vals[2*int(i)-2], vals[2*int(i)-1], maxY);
      norm[2 * normlength] = int(width * 0.1 + ((xVal - minX) / xDiff) * width * 0.8);
      norm[2 * normlength + 1] = int(height * 0.1);
      data[2 * normlength] = xVal;
      data[2 * normlength + 1] = maxY;
      normlength++;

      xVal = getIntersection(vals[2*int(i)], vals[2*int(i)+1], vals[2*int(i)-2], vals[2*int(i)-1], minY);
      norm[2 * normlength] = int(width * 0.1 + ((xVal - minX) / xDiff) * width * 0.8);
      norm[2 * normlength + 1] = int(height * 0.9);
      data[2 * normlength] = xVal;
      data[2 * normlength + 1] = minY;
      normlength++;
      prevOut = -1;
    }
  }
}

int binSearch (float[] arr, float c)
{
  ////println ("------------binsearch for " + c + "-------------------");
  int len = arr.length / 2;
  int max = len - 1;
  int min = 0;
  int imid = 0;
  // continue searching while [imin,imax] is not empty
  while (min <= max)
  {
    /* calculate the midpoint for roughly equal partition */
    imid = int((min + max) / 2);

    // determine which subarray to search
    if (arr[2*imid] < c)
    {
      ////println ("imid < c");
      ////println ("arr[2*imid] = " + arr[2*imid]);
      // change min index to search upper subarray
      min = imid + 1;
    }
    else if (arr[2*imid] > c)
    {
      ////println ("imid > c");
      ////println ("arr[2*imid] = " + arr[2*imid]);
      // change max index to search lower subarray
      max = imid - 1;
    }
    else
      // key found at index imid
      return imid;
    ////println("imid = " + imid + " min = " + min + " max = " + max);
    ////println ("arr[imid] = " + arr[imid] + "arr[min] = " + arr[min] + " arr[max] = " + arr[max]);
  }
  return imid;
}

boolean inBounds (int v)
{
  if (v >= 0 && v < vals.length/2)
    return true;
  else
    return false;
}

void drawLine ()
{
  if (renorm)
  {
    maxXPos = binSearch (vals, maxX);
    while (inBounds (maxXPos) && vals[2*maxXPos] > maxX)
      maxXPos = maxXPos - 1;
    minXPos = binSearch (vals, minX);
    while (inBounds (minXPos) && vals[2*minXPos] < minX)
      minXPos = minXPos + 1;
    //println("minXPos = " + minXPos + " maxXPos = " + maxXPos);
    ////println("vals[minXPos] = " + vals[2*minXPos] + " vals[maxXPos] = " + vals[2*maxXPos]);
    ////println("vals[minXPos-1] = " + vals[2*(minXPos-1)]);
    length = maxXPos - minXPos;
    //println("Bnormalise");
    if (minXPos < maxXPos)
      normalise();
    //println("Anormalise");
    renorm = false;
  }

  ////println ("normlength = " + normlength);

  //int prev = minXPos;
  //float i;

  // int overrange_pos = 0;
  // boolean was_overrange = false;

  // while (overrange_pos < overrange.length && minXPos > overrange[overrange_pos])
  // {
  //   overrange_pos++;
  // }

  stroke(#FF0000);

  strokeWeight(0.5);

  for ( int i = 1; i < normlength; i++)
  {
    ////println ("i = " + i);
    //if (norm[2*int(i)] != -1.0)
    //{
    // if (overrange.length > 0){
    //   if (minXPos + i == overrange[overrange_pos] || minXPos + i+1 == overrange[overrange_pos])
    //   {
    //     stroke(#000000);
    //     strokeWeight(2);
    //     was_overrange = true;
    //   }
    //   else if (was_overrange)
    //   {
    //     stroke(#FF0000);
    //     strokeWeight(0.5);
    //     was_overrange = false;
    //     overrange_pos++;
    //   }
    // }

    line(norm[2 * i - 2], norm[2 * i - 1], norm[2 * i], norm[2 * i + 1]);
    //text(int(i), norm[2*int(i)], norm[2*int(i) + 1]);
    //prev = int(i);
    //}
  }
  // findClosestToMouse();
  // text(timestampToTime(data[2*mouse] + minXVal) + ", " + formatFloat(data[2*mouse+1], 2), norm[2 * mouse] + 11, norm[2 * mouse + 1]);
  // arc (norm[2 * mouse], norm[2 * mouse + 1], 10, 10, 0, TWO_PI);
  //text ("" + mouseX, 10, 10);
}

void drawOverrange()
{
  //println("drawOverrange");
  stroke(#000000);
  strokeWeight(1);
  for (i = 0; i < overrange.length; i++)
  {
    if (vals[2*overrange[i]] > minX && vals[2*overrange[i]] < maxX && vals[2*overrange[i] + 1] > minY && vals[2*overrange[i] + 1] < maxY)
    {
      x = int(width * 0.1 + ((vals[2*overrange[i]]-minX) / xDiff) * width * 0.8);
      y = int(height * 0.9 - ((vals[2*overrange[i] + 1]-minY) / yDiff) * height * 0.8);
      arc (x, y, 3, 3, 0, TWO_PI);
    }

    // line(x1,y1,x2,y2);
    // line(x2,y2,x3,y3);

  }
}

float normPoint(int p)
{

}

void findClosestToMouse()
{
  //float normMouseX = mouseX;
  float minDist = 50000.0;
  float dist;
  for (int i = 0; i < normlength; i++)
  {
    dist = abs(mouseX - norm[2 * i]) + abs(mouseY - norm[2*i + 1]);
    if (dist < minDist)
    {
      mouse = i;
      minDist = dist;
    }
  }
}

//Draws the axes for the line graph, the min and max values are the extrem values on each axes. nX and
//nY determine the amount "number labels" on the axes. So if minX = 0, maxX = 10 and nX = 5, the x
//axis will have the points 0,2,4,6,8,10 labeled. 
void drawAxes(String heading, String xName, String yName, int nX, int nY)
{
  float xStep = 0.8 * width/nX, yStep = 0.8 * height/nY;
  float xGap = (maxX - minX)/float(nX), yGap = (maxY - minY)/float(nY);

  strokeWeight(2);
  stroke(#DCDCDC);
  float pos = 0.1 * height;
  float val = maxY;
  String temp;
  if (!simple){
    for (int i = 0; i < nY; i++)
    {
      text(formatFloat(val, 2), width * 0.05, pos + 3);
      strokeWeight(0.5);
      line (width * 0.1, pos, width * 0.9, pos);
      strokeWeight(2);
      pos = pos + yStep;
      val = val - yGap;
    }
    text(formatFloat(val, 2), width * 0.05, pos + 3);
  }

  
  stroke(#FF0000);

  findClosestToMouse();
  text(timestampToTime(data[2*mouse] + minXVal) + ", " + formatFloat(data[2*mouse+1], 2), norm[2 * mouse] + 11, norm[2 * mouse + 1]);
  arc (norm[2 * mouse], norm[2 * mouse + 1], 10, 10, 0, TWO_PI);

  stroke(0);


  if(!simple)
    line (width * 0.1, height * 0.1, width * 0.1, height * 0.9);
  line (width * 0.1, height * 0.9, width * 0.9, height * 0.9);
  pos = 0.1 * width;
  val = minXVal + minX;
  temp = timestampToTime(val);
  text (temp, pos - (temp.length() * 3), height * 0.95);
  pos = pos + xStep;
  val = val + xGap;
  for (int i = 0; i < nX; i++)
  {
    line (pos, height * 0.9, pos, height * 0.895);
    temp = timestampToTime(val);
    text (temp, pos - (temp.length() * 3), height * 0.95);
    pos = pos + xStep;
    val = val + xGap;
  }

  fill(0);
  text(heading, width * 0.5 - (heading.length() * 4), height * 0.05);
  text (xName, width * 0.5, height);
  translate(width*0.02, height * 0.5);
  rotate (-HALF_PI);
  if (!simple)
    text (yName, 0, 0);
}

//SELECTION CODE

void drawSelection()
{
  noFill();
  stroke (255, 0, 0);
  rectMode(CORNERS);
  rect(selectX, selectY, pmouseX, pmouseY);
  stroke(0);
}

//



String timestampToTime (int timestamp)
{
  int seconds = int(timestamp % 60);
  int minutes = int((timestamp / 60) % 60);
  int hours = int((timestamp / 3600) % 24 + 2);
  ret = formatInt(hours,2) + ":" +  formatInt(minutes,2) + ":" + formatInt(seconds,2);
  //println("From " + timestamp + "to" + ret);
  return ret;
}

String formatInt(int i, int r)
{
  String num = String(i);
  while (num.length() < r)
  {
    num = "0" + num;
  }
  return num;
}

String formatFloat (float f, int r)
{
  String original = str(f);

  String ret = str(floor(f));
  int nRight = original.length() - ret.length();
  ////println (original.charAt(ret.length() + 1) + " nRight = " + nRight);
  if (nRight >= r + 1)
    ret = ret + original.substring(ret.length(), ret.length() + r + 1);
  else if (nRight == 2 && original.charAt(ret.length() + 1) != '0')
    ret = ret + original.substring(ret.length(), ret.length() + nRight);
  else if (nRight > 2)
    ret = ret + original.substring(ret.length(), ret.length() + nRight);
  return ret;
}

