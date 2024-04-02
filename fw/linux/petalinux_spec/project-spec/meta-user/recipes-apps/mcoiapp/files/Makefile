# Makefile - MCOI XU5
# creator: Petr Pacner | CERN | 2024
#

TARGET = mcoicore

# # Path
PROJECT_DIR = .

# # Variables
CFLAGS   =  -g -Wall
OBJS     =  mcoicore.o
INCLUDES =  -I $(PROJECT_DIR)

all: build

build: $(TARGET)

%.o:%.c
	@echo "Compiling $< to $@"
	$(CC) -c $< $(CFLAGS) $(INCLUDES)

$(TARGET): $(OBJS)
	@echo "Linking $< to $@" 
	$(CC) -o $@ $(OBJS) \
		$(CFLAGS) \
		$(INCLUDES) \
		$(LDFLAGS) \
		$(LDLIBS)

clean:
	rm -rf *.o
	rm -rf $(TARGET)
