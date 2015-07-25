install.packages("dplyr");
library(dplyr);

#Getting the 561 headers ready for x_test and x_train so we can tell what variables involve mean and s.d.
features<-read.table("./UCI HAR Dataset/features.txt");
header<-features$V2;

mean_std_col<-grep("mean()|std()",header,ignore.case=TRUE); ##Finding the columns involve mean and s.d.

#Importing the test data 
x_test<-read.table("./UCI HAR Dataset/test/X_test.txt",col.names = header); ##the 561 headers have been previously prepared 
                                                                            ##names(x_test) can reveal whether the headers are fitting nicely 
x_test<-x_test[,mean_std_col];

y_test<-read.table("./UCI HAR Dataset/test/y_test.txt");
y_test<-rename(y_test,Activity_No=V1); ##Indicating what the people are doing  

subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt");
subject_test<-rename(subject_test,ID=V1); ##Assigning an ID to each of the 30 volunteers 


#Importing the training data (similar as above)
x_train<-read.table("./UCI HAR Dataset/train/X_train.txt",col.names = header);
x_train<-x_train[,mean_std_col];

y_train<-read.table("./UCI HAR Dataset/train/y_train.txt");
y_train<-rename(y_train,Activity_No=V1);

subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt");
subject_train<-rename(subject_train,ID=V1);

#Binding the columns
test<-cbind(subject_test,y_test,x_test);
train<-cbind(subject_train,y_train,x_train);

#Binding the rows - which are test and training 
df<-rbind(test,train);

#Changing the Activity column from numeric to meaningful words
activity.labels<-read.table("./UCI HAR Dataset/activity_labels.txt",col.names = c("Activity_No","Activity"))

df=merge(df,activity.labels,by.x="Activity_No",by.y="Activity_No",all=TRUE)
df<-select(df,-(Activity_No))  ##Getting rid of the numbers after we have the wordy column 

df<-arrange(df,ID)

#Appropriately yet painfully labeling the data set with descriptive variable names
names(df)<-gsub("Jerk","_Jerk_Signals",names(df),ignore.case = TRUE)
names(df)<-gsub("Mag|Magnitude","_Magnitude",names(df),ignore.case = TRUE)

names(df)<-gsub("tBody","Time_of_Body",names(df),ignore.case = TRUE)
names(df)<-gsub("fBody","Frequency_of_Body",names(df),ignore.case = TRUE)

names(df)<-gsub("tGravity","Time_of_Gravity",names(df),ignore.case = TRUE)
names(df)<-gsub("fGravity","Frequency_of_Gravity",names(df),ignore.case = TRUE)

names(df)<-gsub("Acc","_Linear_Acceleration",names(df),ignore.case = TRUE)
names(df)<-gsub("Gyro","_Gyroscope",names(df),ignore.case = TRUE)

names(df)<-gsub(".mean()","_Mean",names(df),ignore.case = TRUE)
names(df)<-gsub(".std","_Standard_Deviation",names(df),ignore.case = TRUE)


#Casting the data frame to get the mean value for each variable grouped by Activity and ID
Melt<-melt(df,id=c("ID","Activity"))  ##Melt the data frame to narrow form 
Data<-dcast(Melt,ID~Activity,mean)    ##Get the average for each activity and each ID


#Exporting the final data frame
write.table(Data,file="./noteasy.txt",row.names = FALSE)