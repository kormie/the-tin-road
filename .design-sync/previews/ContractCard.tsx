import React from "react";
import { ContractCard, Stack } from "@tin-road/design-system";

export const Offered = () => (
	<ContractCard
		name="The Urtenu consignment"
		holder="House Urtenu"
		terms="carriage silver every leg, callable wherever Urtenu's factors fly their sail"
		onSign={() => {}}
		signLabel="Sign the consignment"
	/>
);

export const InForce = () => (
	<ContractCard
		name="The storm pledge"
		holder="the temple of the storm god"
		terms="the god's hand over the bad crossings, tithed in daylight each time it is needed"
		signed
	/>
);

export const SideBySide = () => (
	<Stack>
		<ContractCard
			name="The sojourner's right"
			holder="the guild hall of Alashiya"
			terms="standing at the Alashiyan guild hall, arranged from Ugarit before the sail"
			onSign={() => {}}
			signLabel="Sign the sojourner's right"
		/>
		<ContractCard
			name="The storm pledge"
			holder="the temple of the storm god"
			terms="the god's hand over the bad crossings, tithed in daylight each time it is needed"
			signed
		/>
	</Stack>
);
