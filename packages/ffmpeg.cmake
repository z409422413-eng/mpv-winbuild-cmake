ExternalProject_Add(ffmpeg
    DEPENDS
        amf-headers
        nvcodec-headers
        libass              # 必须保留：用于完美渲染 MKV 内部的特效字幕
        libplacebo          # 2026现代 mpv 渲染画面高品质色彩必备
        fontconfig          # 字体库支持（libass 依赖）
        harfbuzz            # 字体塑形支持（libass 依赖）
    GIT_REPOSITORY https://github.com
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--sparse --filter=tree:0"
    GIT_CLONE_POST_COMMAND "sparse-checkout set --no-cone /* !tests/ref/fate"
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} CONF=1 <SOURCE_DIR>/configure
        --cross-prefix=${TARGET_ARCH}-
        --prefix=${MINGW_INSTALL_PREFIX}
        --arch=${TARGET_CPU}
        --target-os=mingw32
        --pkg-config-flags=--static
        --enable-cross-compile
        --enable-runtime-cpudetect
        --enable-gpl
        --enable-version3
        --enable-libass
        --enable-libplacebo
        --enable-libfontconfig
        --enable-libharfbuzz
        
        # ==========================================
        # 核心瘦身：先禁用所有内容
        # ==========================================
        --disable-everything
        
        # ==========================================
        # 容器格式支持（解复用器 Demuxer）
        # ==========================================
        --enable-demuxer=mov,mp4,m4a,3gpp,3gp,matroska
        
        # ==========================================
        # 视频与音频解码支持 (Decoder)
        # ==========================================
        # 视频：覆盖 MP4/MKV 主流的 H264、HEVC(H265)、VP9 和现代的 AV1
        --enable-decoder=h264,hevc,vp9,av1
        # 音频：覆盖 MP4/MKV 常见的 AAC、MP3、FLAC、Opus、AC3(杜比)、DTS
        --enable-decoder=aac,mp3,flac,opus,vorbis,ac3,dca
        
        # ==========================================
        # 辅助解析器 (Parser) 与 字节流过滤器 (BSF)
        # ==========================================
        --enable-parser=h264,hevc,vp9,av1,aac,mpegaudio,flac
        --enable-bsf=h264_mp4toannexb,hevc_mp4toannexb,vp9_superframe,av1_frame_merge
        
        # ==========================================
        # Windows 硬件加速支持
        # ==========================================
        --enable-dxva2
        --enable-d3d11va
        --enable-cuda-llvm
        --enable-cuvid
        --enable-nvdec
        --enable-nvenc
        --enable-amf
        
        # ==========================================
        # 基础组件关闭（保持原样）
        # ==========================================
        --disable-doc
        --disable-ffplay
        --disable-ffprobe
        --disable-vdpau
        --disable-videotoolbox
        ${ffmpeg_lto}
        --extra-cflags='-Wno-error=int-conversion'
        "--extra-libs='${ffmpeg_extra_libs}'"
    BUILD_COMMAND ${MAKE}
    INSTALL_COMMAND ${MAKE} install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(ffmpeg)
cleanup(ffmpeg install)
