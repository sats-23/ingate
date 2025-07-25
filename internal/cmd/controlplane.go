/*
Copyright 2025 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package cmd

import (
	// builtin
	"flag"

	//external
	"github.com/spf13/cobra"
	"k8s.io/klog/v2"

	//internal
	"github.com/kubernetes-sigs/ingate/internal/controlplane"
)

func StartControlPlaneCommand() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "start",
		Aliases: []string{"start", "s"},
		Short:   "Start InGate controller",
		RunE: func(cmd *cobra.Command, args []string) error {
			return controlplane.Start()
		},
	}

	// Initialize klog flags
	klog.InitFlags(nil)

	// Add klog flags to Cobra
	cmd.PersistentFlags().AddGoFlagSet(flag.CommandLine)

	return cmd
}
