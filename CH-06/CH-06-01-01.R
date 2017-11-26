########################################################
# Description:
# 1.for Book 'R with applications to financial quantitive analysis'
# 2.Chapter: CH-06-01-01
# 3.Section: 6.1
# 4.Purpose: GARCH modeling
# 5.Author: Qifa Xu
# 6.Founded: Dec 09, 2013.
# 7.Revised: Aug 06, 2014.
########################################################
# Contents:
# 1. Load package
# 2. Simulate a univariate ARCH time series model
# 3. Simulate a univariate GARCH time series model
#########################################################

# 0. ��ʼ��
setwd('F:/programe/book/R with application to financial quantitive analysis/CH-06')
rm(list=ls())

# 1. ���ذ�
library(fGarch)

# 2. ģ��һԪARCHʱ������ģ��
# (1) simulate ARCH(1) model
set.seed(12345)
spec_1 <- garchSpec(model=list(omega=0.01, alpha=0.85, beta=0))
simdata_1 <- garchSim(spec_1, n=200, extended=TRUE)
class(simdata_1)
plot(simdata_1)
par(mfrow=c(1,3))
acf(simdata_1$eps, main='(a) �в�����', xlab='�ͺ���')
acf(simdata_1$garch, main='(b) ģ������', xlab='�ͺ���')
acf(simdata_1$garch^2, main='(c) ģ������ƽ��', xlab='�ͺ���')
par(mfrow=c(1,1))

# (2) ARCH effect test
library(FinTS)
ArchTest(x=simdata_1$garch, lags=12)
ArchTest(x=simdata_1$eps, lags=12)

# 3. ģ��һԪGARCHʱ������ģ��
# (1) simulate GARCH(1,1) model
set.seed(12345)
spec_2 <- garchSpec(model=list(omega=0.01, alpha=0.85, beta=0.1))
simdata_2 <- garchSim(spec_2, n=200, extended=TRUE)
class(simdata_2)
par(mfrow=c(1,3))
plot(c(simdata_2$eps), type='l', xlab='��', ylab='', main='(a) �в�����')
plot(c(simdata_2$garch), type='l', xlab='��', ylab='', main='(b) ģ������')
plot(c(simdata_2$sigma), type='l', xlab='��', ylab='', main='(c) ������׼��')
par(mfrow=c(1,1))

par(mfrow=c(1,3))
acf(simdata_2$eps, xlab='�ͺ���', main='(a) �в�����')
acf(simdata_2$garch, xlab='�ͺ���', main='(b) ģ������')
acf(simdata_2$garch^2, xlab='�ͺ���', main='(c) ģ������ƽ��')
par(mfrow=c(1,1))

# 4. ��6-4����������-GARCHģ��
# (1) read data
library(quantmod)                                           # ���ذ�
getSymbols('^HSI', from='1989-12-01', to='2013-11-30')      # ��Yahoo��վ���غ���ָ���ռ۸�����
dim(HSI)                                                    # ���ݹ�ģ
names(HSI)                                                  # ���ݱ�������
chartSeries(HSI, theme='white')                             # �����۸��뽻�׵�ʱ��ͼ

HSI <- read.table('HSI.txt')                                # ���ߴ�Ӳ���ж�ȡ����ָ���ռ۸�����
HSI <- as.xts(HSI)                                          # �����ݸ�ʽת��Ϊxts��ʽ

# (2) compute return series
ptd.HSI <- HSI$HSI.Adjusted                                 # ��ȡ�����̼���Ϣ
rtd.HSI <- diff(log(ptd.HSI))*100                           # �����ն�������
rtd.HSI <- rtd.HSI[-1,]                                     # ɾ��һ��ȱʧֵ
plot(rtd.HSI)                                               # �������������е�ʱ��ͼ

ptm.HSI <- to.monthly(HSI)$HSI.Adjusted                     # ��ȡ�����̼���Ϣ
rtm.HSI <- diff(log(ptm.HSI))*100                           # �����¶�������
rtm.HSI <- rtm.HSI[-1,]                                     # ɾ��һ��ȱʧֵ
plot(rtm.HSI)                                               # �������������е�ʱ��ͼ
detach(package:quantmod)

# (3) ARCHЧӦ����
# rtm.HSI <- as.numeric(rtm.HSI)
ind.outsample <- sub(' ','',substr(index(rtm.HSI), 4, 8)) %in% '2013'   # �����������±꣺2013��Ϊ������
ind.insample <- !ind.outsample                                          # �����������±꣺����Ϊ������
rtm.insample <- rtm.HSI[ind.insample]
rtm.outsample <- rtm.HSI[ind.outsample]
Box.test(rtm.insample, lag=12, type='Ljung-Box')                        # ���������в����������
Box.test(rtm.insample^2, lag=12, type='Ljung-Box')                      # ƽ�����������д��������

FinTS::ArchTest(x=rtm.insample, lags=12)                                # ����������ARCHЧӦ

# (4) ģ�Ͷ���
epst <- rtm.insample - mean(rtm.insample)                               # ��ֵ������������
par(mfrow=c(1,2))
acf(as.numeric(epst)^2, lag.max=20, main='ƽ������')
pacf(as.numeric(epst)^2, lag.max=20, main='ƽ������')                               

# (5) ����GARCH��ģ��
GARCH.model_1 <- garchFit(~garch(1,1), data=rtm.insample, trace=FALSE)                    # GARCH(1,1)-Nģ��
GARCH.model_2 <- garchFit(~garch(2,1), data=rtm.insample, trace=FALSE)                    # GARCH(1,2)-Nģ��
GARCH.model_3 <- garchFit(~garch(1,1), data=rtm.insample, cond.dist='std', trace=FALSE)   # GARCH(1,1)-tģ��
GARCH.model_4 <- garchFit(~garch(1,1), data=rtm.insample, cond.dist='sstd', trace=FALSE)  # GARCH(1,1)-stģ��
GARCH.model_5 <- garchFit(~garch(1,1), data=rtm.insample, cond.dist='ged', trace=FALSE)   # GARCH(1,1)-GEDģ��
GARCH.model_6 <- garchFit(~garch(1,1), data=rtm.insample, cond.dist='sged', trace=FALSE)  # GARCH(1,1)-SGEDģ��

summary(GARCH.model_1)
summary(GARCH.model_3)

plot(GARCH.model_1)                                                                       # �������Ӧ���ֻ�ȡ��Ϣ

# (6) ��ȡGARCH��ģ����Ϣ
vol_1 <- fBasics::volatility(GARCH.model_1)                   # ��ȡGARCH(1,1)-Nģ�͵õ��Ĳ����ʹ���
sres_1 <- residuals(GARCH.model_1, standardize=TRUE)          # ��ȡGARCH(1,1)-Nģ�͵õ��ı�׼���в�
vol_1.ts <- ts(vol_1, frequency=12, start=c(1990, 1))
sres_1.ts <- ts(sres_1, frequency=12, start=c(1990, 1))
par(mfcol=c(2,1))
plot(vol_1.ts, xlab='��', ylab='������')
plot(sres_1.ts, xlab='��', ylab='��׼���в�')

# (7) ģ�ͼ���
par(mfrow=c(2,2))
acf(sres_1, lag=24)
pacf(sres_1, lag=24)
acf(sres_1^2, lag=24)
pacf(sres_1^2, lag=24)

par(mfrow=c(1,1))
qqnorm(sres_1)
qqline(sres_1)

# (8) ģ��Ԥ��
pred.model_1 <- predict(GARCH.model_1, n.ahead = 11, trace = FALSE, mse = 'cond', plot=FALSE)
pred.model_2 <- predict(GARCH.model_2, n.ahead = 11, trace = FALSE, mse = 'cond', plot=FALSE)
pred.model_3 <- predict(GARCH.model_3, n.ahead = 11, trace = FALSE, mse = 'cond', plot=FALSE)
pred.model_4 <- predict(GARCH.model_4, n.ahead = 11, trace = FALSE, mse = 'cond', plot=FALSE)
pred.model_5 <- predict(GARCH.model_5, n.ahead = 11, trace = FALSE, mse = 'cond', plot=FALSE)
pred.model_6 <- predict(GARCH.model_6, n.ahead = 11, trace = FALSE, mse = 'cond', plot=FALSE)

predVol_1 <- pred.model_1$standardDeviation
predVol_2 <- pred.model_2$standardDeviation
predVol_3 <- pred.model_3$standardDeviation
predVol_4 <- pred.model_4$standardDeviation
predVol_5 <- pred.model_5$standardDeviation
predVol_6 <- pred.model_6$standardDeviation
et <- abs(rtm.outsample - mean(rtm.outsample))
rtd.HSI.2013 <- rtd.HSI['2013']
rv <- sqrt(aggregate(rtd.HSI.2013^2, by=substr(index(rtd.HSI.2013), 1, 7), sum))

predVol <- round(rbind(predVol_1,predVol_2,predVol_3,predVol_4,predVol_5,predVol_6, 
                       as.numeric(et), as.numeric(rv)), digits=3)
colnames(predVol) <- 1:11
rownames(predVol) <- c('GARCH(1,1)-Nģ��','GARCH(1,2)-Nģ��','GARCH(1,1)-tģ��','GARCH(1,1)-stģ��',
                       'GARCH(1,1)-GEDģ��','GARCH(1,1)-SGEDģ��','�в����ֵ', '��ʵ�ֲ���')
print(predVol)

# (9) ģ��ѡ��
cor(t(predVol))

# 5. ��6-5����������, GARCH-Mģ�͡�TGARCHģ����APARCHģ��
library(rugarch)
# (1) GARCH-Mģ��
GARCHM.spec <- ugarchspec(variance.model=list(model='fGARCH', garchOrder=c(1,1), submodel='GARCH'), 
                          mean.model=list(armaOrder=c(0,0), include.mean=TRUE, archm=TRUE),
                          distribution.model='norm')
GARCHM.fit <- ugarchfit(GARCHM.spec, data=rtm.insample)

# (2) TGARCHģ��
TGARCH.spec <- ugarchspec(variance.model=list(model='fGARCH', garchOrder=c(1,1), submodel='TGARCH'), 
                          mean.model=list(armaOrder=c(0,0), include.mean=TRUE, archm=FALSE),
                          distribution.model='norm')
TGARCH.fit <- ugarchfit(TGARCH.spec, data=rtm.insample)

# (3) APARCHģ��
APARCH.model_1 <- garchFit(~1+aparch(1,1), data=rtm.insample, trace=FALSE)                    # GARCH(1,1)-Nģ��
summary(APARCH.model_1)
APARCH.model_2 <- garchFit(~1+aparch(1,1), data=rtm.insample, delta=2, trace=FALSE)                    # GARCH(1,1)-Nģ��
summary(APARCH.model_2)

# 6. ��6-6����������, MGARCHģ��
library(rmgarch)
library(xts)
library(xlsx)

# (1) CCC-GARCH




# (2) DCC-GARCHģ��
StockExchange <- read.xlsx(file='Data.xlsx', sheetIndex='StockExchange')
rstock <- diff(log(StockExchange$stock))            # �������������
rexchange <- diff(log(StockExchange$exchange))      # �������������
r.StockExchange <- data.frame(rstock=rstock, rexchange=rexchange, row.names=StockExchange$date[-1])
r.StockExchange <- as.xts(r.StockExchange)          # ת��Ϊʱ�����нṹ
par(mfrow=c(2,1))                                   # ʱ������ͼ��
plot(r.StockExchange$rstock, ylab='������',main='����300',lty=1,cex.lab=0.8,cex.main=0.8)
plot(r.StockExchange$rexchange, ylab='������',main='����',lty=1,cex.lab=0.8,cex.main=0.8)

garch11.spec <- ugarchspec(mean.model = list(armaOrder = c(1,1),include.mean =TRUE),
                           variance.model = list(garchOrder = c(1,1),model = "eGARCH"),
                           distribution.model = "sstd")        # �趨GARCH��DCC����
dcc.garch11.spec <- dccspec(uspec = multispec(replicate(2,garch11.spec)),VAR=FALSE,dccOrder = c(1,1),distribution="mvt")
dcc.fit = dccfit(dcc.garch11.spec, data=r.StockExchange)      # DCC����
dcc.fit                                                       # ��ʾDCC���ƽ��

plot(dcc.fit)                                                 # DCC������������Ҫ�����һ�����֣�1-5��
dcc.fcst = dccforecast(dcc.fit, n.ahead=20)                   # ����Ԥ��
plot(dcc.fcst)                                                # ��ʾ����Ԥ�⣬����Ҫ�����һ�����֣�1-5��


