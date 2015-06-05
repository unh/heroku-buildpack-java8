#!/usr/bin/env bash

export_env_dir() {
  env_dir=$1
  whitelist_regex=${2:-''}
  blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH|JAVA_OPTS)$'}
  if [ -d "$env_dir" ]; then
    for e in $(ls $env_dir); do
      echo "$e" | grep -E "$whitelist_regex" | grep -qvE "$blacklist_regex" &&
      export "$e=$(cat $env_dir/$e)"
      :
    done
  fi
}

install_oracle_java() {
  cache_dir=$1
  build_dir=$2  
  jdk_url=${3:-"http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.tar.gz"}
  jdk_ver=${4:-"1.8.0_45"}
  
  if [ ! -d "${cache_dir}" ]; then error "Invalid cache directory to store JDK."; fi
  if [ ! -d "${build_dir}" ]; then error "Invalid slug directory to install JDK."; fi
  
  mkdir -p "${build_dir}/.jdk"
  
  if [ ! -f "${cache_dir}/.jdk/bin/java" ]; then
    echo -n " (downloading...)"
    rm -rf "${cache_dir}/.jdk" && mkdir -p "${cache_dir}/.jdk"
    curl -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" "${jdk_url}" | tar xz -C "${cache_dir}/.jdk" --strip-components=1
    rm -rf "${cache_dir}/.jdk/src.zip" "${cache_dir}/.jdk/javafx-src.zip" "${cache_dir}/.jdk/db" "${cache_dir}/.jdk/man"
  fi
  cp -r "${cache_dir}/.jdk/." "${build_dir}/.jdk"
  
  if [ ! -f "${build_dir}/.jdk/bin/java" ]; then
    error "Unable to retrieve JDK."
  fi
  
  export JAVA_HOME="${build_dir}/.jdk"
  export PATH="${build_dir}/.jdk/bin:${PATH}"
}

java_version() {
  base=$1
  echo $(${base}java -version 2>&1 | head -n 1 | cut -d '"' -f 2)
}
