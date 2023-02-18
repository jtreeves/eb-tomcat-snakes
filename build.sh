cd src
mkdir -p WEB-INF/classes
echo .
javac -d WEB-INF/classes com/snakes/model/Media.java
echo .
javac -classpath WEB-INF/lib/*:WEB-INF/classes -d WEB-INF/classes com/snakes/model/Movie.java
echo .
javac -classpath WEB-INF/lib/*:WEB-INF/classes -d WEB-INF/classes com/snakes/web/ListMovies.java
echo .
javac -classpath WEB-INF/lib/*:WEB-INF/classes -d WEB-INF/classes com/snakes/web/AddMovie.java
echo .
javac -classpath WEB-INF/lib/*:WEB-INF/classes -d WEB-INF/classes com/snakes/web/SearchMovies.java
echo .
if [ -d ".ebextensions/httpd/conf.d" ]; then
  jar -cf ROOT.war *.jsp images css js WEB-INF .ebextensions/*.config .ebextensions/*.json .ebextensions/httpd/conf.d/*.conf
else
  jar -cf ROOT.war *.jsp images css js WEB-INF .ebextensions/*.config .ebextensions/*.json
fi
echo .
if [ -d "/opt/homebrew/Cellar/tomcat/10.1.5/libexec/webapps" ]; then
  cp ROOT.war /opt/homebrew/Cellar/tomcat/10.1.5/libexec/webapps
  echo .
fi
mv ROOT.war ../
echo .
echo "SUCCESS"
