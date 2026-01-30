
PKG_CONFIG := pkg-config

OPENCV_OK := $(shell $(PKG_CONFIG) --exists opencv4 && echo yes || echo no)
SDL_OK    := $(shell $(PKG_CONFIG) --exists sdl2 && echo yes || echo no)

OS := $(shell . /etc/os-release 2>/dev/null && echo $$ID_LIKE)

install:
	@echo "Checking dependencies..."

ifeq ($(OPENCV_OK),yes)
ifeq ($(SDL_OK),yes)
	@echo "OpenCV and SDL already installed"
	@exit 0
endif
endif

	@echo "installing missing dependencies..."

ifneq (,$(findstring ubuntu,$(OS)))
	@sudo apt update -y
	@sudo apt install -y \
		build-essential \
		make \
		pkg-config \
		libopencv-dev \
		libsdl2-dev \
		libsdl2-image-dev

else ifneq (,$(findstring debian,$(OS)))
	@sudo apt update -y
	@sudo apt install -y \
		build-essential \
		make \
		pkg-config \
		libopencv-dev \
		libsdl2-dev \
		libsdl2-image-dev

else ifneq (,$(findstring arch,$(OS)))
	@sudo pacman -Sy --noconfirm \
		base-devel \
		pkg-config \
		opencv \
		sdl2

else ifneq (,$(findstring darwin,$(OS)))
	@brew install pkg-config opencv sdl2

else
	@echo "Unsupported OS: $(OS)"
	@exit 1
endif

	@echo "Dependencies installed successfully"
