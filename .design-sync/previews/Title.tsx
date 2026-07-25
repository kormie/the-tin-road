import React from "react";
import {
	Title, MeanderRule, Chronicle, Entry, Colophon,
} from "@tin-road/design-system";

export const PageTitle = () => <Title>THE TIN ROAD</Title>;

export const OverTheBook = () => (
	<>
		<Title>THE CHRONICLE OF HOUSE SAPANU</Title>
		<MeanderRule />
		<Chronicle>
			<Colophon>As compiled from the House archive. Seed 101.</Colophon>
			<Entry>In the first season of House Sapanu, Gamiradu took up the pen.</Entry>
		</Chronicle>
	</>
);
