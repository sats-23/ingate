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

package controlplane

import (
	"context"
	//external
	"k8s.io/klog/v2"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/builder"
	"sigs.k8s.io/controller-runtime/pkg/predicate"
	gatewayv1 "sigs.k8s.io/gateway-api/apis/v1"
)

func NewGatewayClassReconciler(mgr ctrl.Manager) *GatewayClassReconciler {
	return &GatewayClassReconciler{
		Client: mgr.GetClient(),
		scheme: mgr.GetScheme(),
	}
}

func (r *GatewayClassReconciler) SetupWithManager(ctx context.Context, mgr ctrl.Manager) error {
	klog.Info("setting up gateway class controller")
	return ctrl.NewControllerManagedBy(mgr).
		For(&gatewayv1.GatewayClass{},
			builder.WithPredicates(
				predicate.NewPredicateFuncs(
					matchGWClassControllerName(inGateControllerName)))).
		Complete(r)
}
