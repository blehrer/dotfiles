#!/usr/bin/env bash
date >>"$XIT_INSTALL_DIR"/logs/gen_run_tll_packages.sh.log
java -cp "$XIT_INSTALL_DIR"/"$XIT_DEPLOYMENT_LINK_NAME"/xit.jar com.nbc.xit.Application sl_rest_as_run_job \
  "$XIT_INSTALL_DIR"/"$XIT_DEPLOYMENT_LINK_NAME"/config/recontool/sl_ws_rest_rest_asrun_syfy.yaml \
  "$XIT_HOME_DIR"/packages \
  "$XIT_ENCRYPTION_KEY" \
  "$XIT_SL_CONFIG" >>"$XIT_INSTALL_DIR"/logs/xit-recon-gen.log
date >>"$XIT_INSTALL_DIR"/logs/gen_run_tll_packages.sh.log
"$XIT_INSTALL_DIR"/"$XIT_DEPLOYMENT_LINK_NAME"/scripts/TLL/gen_run_tll_packages.sh >> logs/gen_run_tll_packages.sh.log
